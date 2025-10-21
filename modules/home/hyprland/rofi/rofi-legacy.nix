{ ... }: {
  home.file.".config/rofi/legacy.config.rasi".text = ''
    @theme "/dev/null"

    * {
      /* VM palette fast-match */
      bg:            #282936;
      bg-alt:        #3a3c4e;
      fg:            #f7f7fb;
      acc:           #00f769;  /* bright green */
      cyan:          #62d6e8;
      purple:        #b45bcf;
      yellow:        #ebff87;
      pink:          #ea51b2;
      alt:           #a1efe4;

      background-color: @bg;
      text-color: @fg;
      font: "JetBrainsMono Nerd Font 12";
    }

    configuration {
      modi:                 "run,filebrowser,drun";
      show-icons:           true;
      icon-theme:           "Papirus";
      location:             0;
      drun-display-format:  "{icon} {name}";
      display-drun:         "   Apps ";
      display-run:          "   Run ";
      display-filebrowser:  "   File ";
    }

    window {
      width: 45%;
      transparency: "real";
      orientation: vertical;
      border: 2px;
      border-color: @acc;
      border-radius: 10px;
      background-color: @bg;
      background-image: url("~/.config/rofi/legacy-rofi.jpg", width);
    }

    mainbox {
      children: [ inputbar, listview, mode-switcher ];
      background-color: @bg;        /* solid background for content area */
      margin: 200 0 0 0;            /* push content below banner */
      padding: 0 12 12 12;
    }

    element {
      padding: 8 14;
      text-color: @fg;
      border-radius: 5px;
    }
    element selected {
      text-color: @bg-alt;
      background-color: @cyan;
    }
    element-text { background-color: inherit; text-color: inherit; }
    element-icon { size: 24px; background-color: inherit; padding: 0 6 0 0; alignment: vertical; }

    listview {
      columns: 2;
      lines: 9;
      padding: 8 0;
      fixed-height: true;
      fixed-columns: true;
      fixed-lines: true;
      border: 0 10 6 10;
    }

    entry {
      text-color: @fg;
      padding: 12 16 12 16;  /* symmetrical vertical padding, comfortable horizontal */
      margin: 0;             /* remove negative right margin that can offset content */
    }

    inputbar {
      background-color: @bg-alt;    /* ensure it sits on solid background, not image */
      padding: 12 12 12 12;         /* balanced vertical padding */
      margin: 0 0 12 0;             /* add space below the search field */
    }

    prompt {
      text-color: @purple;
      padding: 12 16 12 16;  /* symmetrical vertical padding to match entry */
      margin: 0;             /* remove negative right margin */
    }

    mode-switcher { border-color: @acc; spacing: 0; }


    button { padding: 10px; background-color: @bg; text-color: #ff3b3b; }
    button selected { background-color: @bg; text-color: @acc; }

    message { background-color: @bg; margin: 2px; padding: 2px; border-radius: 5px; }
    textbox { padding: 6px; margin: 20px 0 0 20px; text-color: @acc; background-color: @bg; }
  '';

  home.file.".config/rofi/legacy-rofi.jpg".source = ../../../../legacy-rofi.jpg;
}

