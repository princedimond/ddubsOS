{host, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;

    # Renamed options: userName/userEmail -> settings.user.{name,email}
    settings = {
      user = {
        name = gitUsername;
        email = gitEmail;
      };

      # extraConfig -> settings
      push.default = "simple"; # Match modern push behavior
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main"; # Set default new branches to 'main'
      log = {
        decorate = "full"; # Show branch/tag info in git log
        date = "iso"; # ISO 8601 date format
      };
      # Conflict resolution style for readable diffs
      merge = {
        conflictStyle = "diff3";
        stat = "true";
      };
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      };
      diff = {colorMoved = "default";};

      # Renamed in Home Manager: aliases -> settings.alias
      alias = {
        br = "branch --sort=-committerdate";
        co = "checkout";
        af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
        com = "commit -a";
        ca = "commit -a";
        df = "diff";
        gs = "stash";
        gp = "pull";
        st = "status";
        lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
        edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; hx `f`";
        pushr = "!git fetch origin && git rebase origin/HEAD && git push origin HEAD";
      };
    };
  };

  # Explicitly enable delta and Git integration; move delta options here
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      true-color = "never";

      features = "unobtrusive-line-numbers decorations";
      unobtrusive-line-numbers = {
        line-numbers = true;
        line-numbers-left-format = "{nm:>4}│";
        line-numbers-right-format = "{np:>4}│";
        line-numbers-left-style = "grey";
        line-numbers-right-style = "grey";
      };
      decorations = {
        commit-decoration-style = "bold grey box ul";
        file-style = "bold blue";
        file-decoration-style = "ul";
        hunk-header-decoration-style = "box";
      };
    };
  };
}
