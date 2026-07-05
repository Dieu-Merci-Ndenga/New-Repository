#!/usr/bin/env python3
import os
import re
import sys
from collections import defaultdict, deque

ROOT = os.getcwd()

nim_files = []
for dirpath, dirs, files in os.walk(ROOT):
    # skip .git and .github artifacts
    if '.git' in dirpath.split(os.sep):
        continue
    for f in files:
        if f.endswith('.nim'):
            nim_files.append(os.path.join(dirpath, f))

import_re = re.compile(r"^\s*(import|from)\s+(.*)")

# map file -> list of module names imported
file_imports = defaultdict(list)

def split_modules(s):
    # remove std/[...] syntax
    s = s.strip()
    s = s.split('#',1)[0]
    # handle std/[a,b]
    m = re.match(r"(\w+)\s*/\s*\[(.*)\]", s)
    if m:
        base = m.group(1)
        inner = m.group(2)
        items = [it.strip() for it in inner.split(',') if it.strip()]
        return [base + '.' + it for it in items]
    # otherwise split by comma
    parts = [p.strip() for p in re.split(r',', s) if p.strip()]
    # remove 'as' suffixes
    res = []
    for p in parts:
        p = p.split(' as ')[0].strip()
        res.append(p)
    return res

for f in nim_files:
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            for line in fh:
                m = import_re.match(line)
                if m:
                    rest = m.group(2)
                    mods = split_modules(rest)
                    for mod in mods:
                        file_imports[f].append(mod)
    except Exception:
        pass

# Build module name -> file path mapping (try mapping dotted names to paths)
module_to_file = {}
for f in nim_files:
    rel = os.path.relpath(f, ROOT)
    modname = os.path.splitext(rel)[0].replace(os.sep, '.')
    module_to_file[modname] = f

# graph: file -> files (edges via imports when module maps to file)
graph = defaultdict(list)
for f, mods in file_imports.items():
    for m in mods:
        # if module is mapped to a local file, add edge
        if m in module_to_file:
            graph[f].append(module_to_file[m])
        else:
            # also try mapping by converting module dotted path to relative path
            candidate = os.path.join(ROOT, *m.split('.')) + '.nim'
            if os.path.exists(candidate):
                graph[f].append(candidate)

# Forbidden module name patterns (impl/legacy)
forbidden_modules = ['git.impl_cli', 'git.impl_libgit2', 'git_engine', 'git_engine.nim']

# Map forbidden module names to files where possible
forbidden_files = set()
for fm in forbidden_modules:
    if fm in module_to_file:
        forbidden_files.add(module_to_file[fm])
    else:
        # try path
        candidate = os.path.join(ROOT, *fm.split('.')) + '.nim'
        if os.path.exists(candidate):
            forbidden_files.add(candidate)

# Also collect files that mention forbidden tokens directly (fallback)
for f in nim_files:
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            txt = fh.read()
            for tok in ['git_engine', 'impl_cli', 'impl_libgit2']:
                if re.search(r'\b' + re.escape(tok) + r'\b', txt):
                    forbidden_files.add(f)
    except Exception:
        pass

def find_paths_to_forbidden(start_file):
    # BFS keeping parent pointers
    q = deque([start_file])
    parent = {start_file: None}
    while q:
        cur = q.popleft()
        if cur in forbidden_files:
            # reconstruct path
            path = []
            node = cur
            while node is not None:
                path.append(node)
                node = parent.get(node)
            path.reverse()
            return path
        for nb in graph.get(cur, []):
            if nb not in parent:
                parent[nb] = cur
                q.append(nb)
    return None

violations = []
for f in nim_files:
    # skip allowed infra files
    rel = os.path.relpath(f, ROOT)
    if rel.startswith('src' + os.sep + 'git' + os.sep) or rel == os.path.join('src','git'):
        continue
    # check direct forbidden mention
    with open(f, 'r', encoding='utf-8') as fh:
        txt = fh.read()
        for tok in ['git.impl_cli', 'impl_cli', 'git_engine', 'impl_libgit2']:
            if re.search(r'\b' + re.escape(tok) + r'\b', txt):
                violations.append((f, [f]))
                break
    # check transitive graph path
    path = find_paths_to_forbidden(f)
    if path:
        violations.append((f, path))

if violations:
    print('Dependency firewall violations detected:\n')
    for v in violations:
        src = v[0]
        path = v[1]
        print('- File: ' + os.path.relpath(src, ROOT))
        print('  Path to forbidden:')
        for p in path:
            print('    -> ' + os.path.relpath(p, ROOT))
        print('')
    sys.exit(2)

print('Import graph validation passed. No forbidden dependency paths found.')
sys.exit(0)
