# wtpr: Thin wrapper around wtree for PR branch review.
# Usage: wtpr [-n|--no-setup] [-r|--run] [--pm npm|pnpm] <branch>
#
# wtree now handles both new branches and existing PR branches automatically:
# if the branch exists on origin it is fetched and checked out as-is;
# otherwise a new branch is created from the base branch.
wtpr() {
  wtree "$@"
}
