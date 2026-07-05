import std/unittest

import forge


suite "forge":
  test "renderSummary formats the repository summary":
    let summary = RepoSummary(
      repositoryPath: "/tmp/repo",
      currentBranch: "main",
      commitCount: 12,
      branchCount: 3
    )

    check renderSummary(summary) == "Repository: /tmp/repo\nCurrent branch: main\nCommits: 12\nBranches: 3\n"