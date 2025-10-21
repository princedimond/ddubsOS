{ ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 655;
      height = 400;
      always_parse_args = true;
      show_all = false;
      term = "kitty";
      hide_scroll = true;
      print_command = true;
      insensitive = true;
      prompt = "";
      columns = 2;
      sort_order = "history"; # prioritize recently used; switch to "alphabetical" if desired
    };
    style = ''
      @define-color rosewater  #f5e0dc;
      @define-color flamingo  #f2cdcd;
      @define-color pink  #f5c2e7;
      @define-color mauve  #cba6f7;
      @define-color red  #f38ba8;
      @define-color maroon  #eba0ac;
      @define-color peach  #fab387;
      @define-color yellow  #f9e2af;
      @define-color green  #a6e3a1;
      @define-color teal  #94e2d5;
      @define-color sky  #89dceb;
      @define-color sapphire  #74c7ec;
      @define-color blue  #89b4fa;
      @define-color lavender  #b4befe;
      @define-color text  #e3ebff; /* brightened from #cdd6f4 */
      @define-color subtext1  #bac2de;
      @define-color subtext0  #a6adc8;
      @define-color overlay2  #9399b2;
      @define-color overlay1  #7f849c;
      @define-color overlay0  #6c7086;
      @define-color surface2  #585b70;
      @define-color surface1  #45475a;
      @define-color surface0  #313244;
      @define-color base  #1e1e2e;
      @define-color mantle  #181825;
      @define-color crust  #11111b;

      * {
        font-family: 'JetBrainsMono Nerd Font', monospace;
        font-size: 15px; /* slightly larger */
        /* Note: GTK CSS used by Wofi does not support text-align; keeping default alignment */
      }

      /* Window */
      window {
        margin: 0px;
        padding: 12px;
        border: 0.30em solid @lavender; /* thicker border */
        border-radius: 1em;
        background-color: @base;
        animation: slideIn 0.5s ease-in-out both;
      }

      /* Slide In */
      @keyframes slideIn {
        0% { opacity: 0; }
        100% { opacity: 1; }
      }

      /* Inner Box */
      #inner-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: @base;
        animation: fadeIn 0.5s ease-in-out both;
      }

      /* Fade In */
      @keyframes fadeIn {
        0% { opacity: 0; }
        100% { opacity: 1; }
      }

      /* Outer Box */
      #outer-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: @base;
      }

      /* Scroll */
      #scroll {
        margin: 0px;
        padding: 10px;
        border: none;
        background-color: @base;
      }

      /* Input */
      #input {
        margin: 5px 20px;
        padding: 10px;
        border: none;
        border-radius: 1em;
        color: @text;
        background-color: @base;
        animation: fadeIn 0.2s ease-in-out both;
      }

      #input image {
        border: none;
        color: @red;
      }

      #input * {
        outline: 4px solid @red!important;
      }

      /* Text */
      #text {
        margin: 5px;
        border: none;
        color: @text; /* brighter */
        animation: fadeIn 0.5s ease-in-out both;
      }

      #entry { background-color: @base; }

      #entry arrow {
        border: none;
        color: @lavender;
      }

      /* Selected Entry */
      #entry:selected {
        border: 0.20em solid @lavender; /* thicker */
      }

      #entry:selected #text { color: @mauve; }

      #entry:drop(active) { background-color: @lavender!important; }

      /* Force consistent backgrounds for multi-column layout */
      #entry,
      #entry * { background-color: @base; }
      #entry:nth-child(even),
      #entry:nth-child(odd) { background-color: @base; }
      #entry:selected { background-color: @base; border: 0.20em solid @lavender; }
      #entry:selected * { background-color: @base; }
      #text { background-color: transparent; }
    '';
  };
}
