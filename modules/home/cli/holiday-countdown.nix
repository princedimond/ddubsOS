{
  pkgs,
  lib,
  ...
}: let
  holidayCountdown = pkgs.stdenv.mkDerivation {
    pname = "holiday-countdown";
    version = "0.1.0";

    src = pkgs.writeTextFile {
      name = "holiday-countdown-main";
      destination = "/main.go";
      text = ''
        package main

        import (
            "flag"
            "fmt"
            "os"
            "time"
        )

        func nextChristmas(now time.Time, loc *time.Location) time.Time {
            y := now.In(loc).Year()
            x := time.Date(y, time.December, 25, 0, 0, 0, 0, loc)
            if !x.After(now.In(loc)) {
                x = x.AddDate(1, 0, 0)
            }
            return x
        }

        func usThanksgiving(year int, loc *time.Location) time.Time {
            // 4th Thursday of November
            d := time.Date(year, time.November, 1, 0, 0, 0, 0, loc)
            // days to next Thursday
            offset := (int(time.Thursday) - int(d.Weekday()) + 7) % 7
            firstThu := d.AddDate(0, 0, offset)
            return firstThu.AddDate(0, 0, 21) // +3 weeks -> 4th Thursday
        }

        func nextThanksgiving(now time.Time, loc *time.Location) time.Time {
            y := now.In(loc).Year()
            t := usThanksgiving(y, loc)
            if !t.After(now.In(loc)) {
                t = usThanksgiving(y+1, loc)
            }
            return t
        }

        func humanDiff(to time.Time, from time.Time) (int, int, int, int) {
            if to.Before(from) {
                from, to = to, from
            }
            dur := to.Sub(from).Truncate(time.Second)
            days := int(dur.Hours()) / 24
            hours := int(dur.Hours()) % 24
            minutes := int(dur.Minutes()) % 60
            seconds := int(dur.Seconds()) % 60
            return days, hours, minutes, seconds
        }

        func usage() {
            fmt.Fprintf(os.Stderr, "Usage:\n  holiday-countdown [options]\n\nOptions:\n  -h, --help   Show this help\n  -es          Español output\n  -jp          日本語 output\n\nExamples:\n  holiday-countdown\n  holiday-countdown -es\n  holiday-countdown -jp\n\n")
        }

        func labels(lang string) (xmas, tkg string) {
            switch lang {
            case "es":
                return "Tiempo hasta Navidad 🎄:", "Tiempo hasta el Día de Acción de Gracias 🦃:"
            case "jp":
                return "クリスマスまでの時間 🎄:", "感謝祭までの時間 🦃:"
            default:
                return "Time until Christmas 🎄:", "Time until Thanksgiving 🦃:"
            }
        }

        func main() {
            // Flags
            var help bool
            var es, jp bool
            flag.BoolVar(&help, "help", false, "show help")
            flag.BoolVar(&help, "h", false, "show help")
            flag.BoolVar(&es, "es", false, "Español output")
            flag.BoolVar(&jp, "jp", false, "日本語 output")
            flag.Usage = usage
            flag.Parse()
            if help {
                flag.Usage()
                return
            }
            lang := "en"
            if jp {
                lang = "jp"
            } else if es {
                lang = "es"
            }

            now := time.Now()
            loc := time.Local

            lights := []string{"\x1b[31m●", "\x1b[32m●", "\x1b[33m●", "\x1b[37m●"}
            pattern := []int{0, 1, 2, 3}

            fmt.Print("   ")
            for i := 0; i < 80; i++ {
                fmt.Print(lights[pattern[i%len(pattern)]])
            }
            fmt.Print("\x1b[0m\n")

            xmas := nextChristmas(now, loc)
            txg := nextThanksgiving(now, loc)

            dx, hx, mx, sx := humanDiff(xmas, now)
            dt, ht, mt, st := humanDiff(txg, now)
            lx, lt := labels(lang)
            fmt.Printf("     %s %d days, %d hours, %d minutes, %d seconds\n", lx, dx, hx, mx, sx)
            fmt.Printf("     %s %d days, %d hours, %d minutes, %d seconds\n", lt, dt, ht, mt, st)

            fmt.Print("   ")
            for i := 0; i < 80; i++ {
                fmt.Print(lights[pattern[i%len(pattern)]])
            }
            fmt.Print("\x1b[0m\n")
        }
      '';
    };

    nativeBuildInputs = [pkgs.go];

    buildPhase = ''
      runHook preBuild
      cp $src/main.go .
      cat > go.mod << 'EOF'
      module holiday-countdown

      go 1.22
      EOF
      # Ensure Go can write caches in the sandbox
      export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
      export GOCACHE="$TMPDIR/go-cache"
      export GOPATH="$TMPDIR/go"
      export GO111MODULE=on
      export GOFLAGS="-buildvcs=false"
      mkdir -p "$XDG_CACHE_HOME" "$GOCACHE" "$GOPATH"
      go build -o holiday-countdown .
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp holiday-countdown $out/bin/
      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI that prints countdowns to upcoming US Thanksgiving and Christmas";
      license = licenses.mit;
      mainProgram = "holiday-countdown";
      platforms = platforms.linux;
    };
  };
in {
  home.packages = [holidayCountdown];
}
