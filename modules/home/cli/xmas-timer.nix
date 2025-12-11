{
  pkgs,
  lib,
  ...
}: let
  xmasTimer = pkgs.stdenv.mkDerivation {
    pname = "xmas-timer";
    version = "0.1.0";

    # Embed the Go source directly so evaluation stays pure
    src = pkgs.writeTextFile {
      name = "xmas-timer-main";
      destination = "/xmas_countdown_timer.go";
      text = ''
        // xmas countdown in go
        // GrumpyDonut
        // November 26, 2025

        package main

        import (
        	"fmt"
        	"math/rand"
        	"os"
        	"os/signal"
        	"strings"
        	"syscall"
        	"time"
        	"unsafe"
        )

        type winsize struct {
        	Row    uint16
        	Col    uint16
        	Xpixel uint16
        	Ypixel uint16
        }

        func getTermSize() (cols, rows int) {
        	ws := &winsize{}
        	_, _, err := syscall.Syscall(syscall.SYS_IOCTL,
        				     uintptr(syscall.Stdout),
        				     uintptr(syscall.TIOCGWINSZ),
        				     uintptr(unsafe.Pointer(ws)))
        	if err != 0 {
        		return 80, 24
        	}
        	return int(ws.Col), int(ws.Row)
        }

        // Snowflake
        type flake struct {
        	x int // column (0..cols-1)
        	y int // row (0..rows-1)
        	// drift -1,0,1
        	drift int
        }

        func hideCursor() { fmt.Print("\033[?25l") }
        func showCursor() { fmt.Print("\033[?25h") }
        func clearScreen() { fmt.Print("\033[2J\033[H") } // clear + cursor home
        func resetColor()  { fmt.Print("\033[0m") }

        func clamp(x, a, b int) int {
        	if x < a {
        		return a
        	}
        	if x > b {
        		return b
        	}
        	return x
        }

        func main() {
        	rand.Seed(time.Now().UnixNano())

        	// handle SIGINT/SIGTERM to restore cursor & color on exit
        	c := make(chan os.Signal, 1)
        	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
        	go func() {
        		<-c
        		cleanupAndExit()
        	}()

        	// hide cursor
        	hideCursor()
        	defer showCursor()
        	defer resetColor()

        	// lights: color codes + visible marker
        	lightsVisible := []rune{'●', '●', '●', '●'}
        	lightsColor := []string{
        		"\033[31m", // red
        		"\033[32m", // green
        		"\033[33m", // yellow
        		"\033[37m", // white
        	}
        	pattern := []int{0, 1, 2, 3}

        	// snow settings
        	//maxFlakesStart := 120 // number of flakes to initialize (will scale with terminal area)
        	var flakes []flake

        	// frame tick — smaller is smoother. If you truly want 1s refresh only, set to time.Second.
        	tickDuration := 200 * time.Millisecond

        	// rotation offset for lights
        	offset := 0

        	// main loop
        	ticker := time.NewTicker(tickDuration)
        	defer ticker.Stop()

        	// christmas location/time zone
        	location, err := time.LoadLocation("America/Chicago")
        	if err != nil {
        		location = time.Local
        	}

        	for {
        		cols, rows := getTermSize()
        		// ensure minimum grid
        		if cols < 20 {
        			cols = 20
        		}
        		if rows < 10 {
        			rows = 10
        		}

        		// ensure flakes count scaled by terminal size
        		area := cols * rows
        		targetFlakes := clamp(area/50, 20, area/3) // heuristic
        		if len(flakes) < targetFlakes {
        			for i := 0; i < (targetFlakes-len(flakes)); i++ {
        				flakes = append(flakes, flake{
        					x:     rand.Intn(cols),
        						y:     rand.Intn(rows),
        						drift: rand.Intn(3) - 1,
        				})
        			}
        		} else if len(flakes) > targetFlakes {
        			flakes = flakes[:targetFlakes]
        		}

        		// Build empty canvas (rows slices of runes)
        		// We'll build as []rune per line; we place characters where needed.
        		canvas := make([][]rune, rows)
        		for r := 0; r < rows; r++ {
        			line := make([]rune, cols)
        			for i := 0; i < cols; i++ {
        				line[i] = ' '
        			}
        			canvas[r] = line
        		}

        		// Place snowflakes on canvas
        		for i := range flakes {
        			f := &flakes[i]
        			// clamp to bounds
        			if f.x < 0 || f.x >= cols {
        				f.x = rand.Intn(cols)
        			}
        			if f.y < 0 || f.y >= rows {
        				f.y = rand.Intn(rows)
        			}
        			// snow character - small chance of sparkle
        			ch := '*'
        			if rand.Intn(8) == 0 {
        				ch = '✦'
        			}
        			canvas[f.y][f.x] = rune(ch)
        		}

        		// Create lights line (visible & colored) for top and bottom
        		lightCount := cols / 2 // number of visible lights to draw (one light takes ~2 cols visually)
        		if lightCount < 10 {
        			lightCount = 10
        		}
        		// Build visible-only string length for centering (each light counts as 1 rune)
        		visibleLights := strings.Repeat("●", lightCount) // just for centering math

        		// Build colored lights string (ANSI escapes)
        		var coloredLightsBuilder strings.Builder
        		for i := 0; i < lightCount; i++ {
        			idx := pattern[(i+offset)%len(pattern)]
        			coloredLightsBuilder.WriteString(lightsColor[idx])
        			coloredLightsBuilder.WriteRune(lightsVisible[idx])
        			// Add a tiny spacer for better visual (but invisible for centering calculations)
        			coloredLightsBuilder.WriteString("\033[0m ") // reset then a space
        		}
        		coloredLights := coloredLightsBuilder.String()
        		resetSeq := "\033[0m"

        		// Compute centered positions for text lines
        		visibleLen := len([]rune(visibleLights)) // number of visible runes
        		padding := (cols - visibleLen) / 2
        		if padding < 0 {
        			padding = 0
        		}
        		lightLineLeftPad := padding

        		// place top lights into canvas row 1 (index 0)
        		topRow := 0
        		// we can't place colored sequence into rune canvas (ANSI sequences), so we'll print colored lines separately.
        		// for alignment we still draw visible markers into the rune grid (to avoid snow overlapping where lights show).
        		for i := 0; i < visibleLen && (lightLineLeftPad+i) < cols; i++ {
        			canvas[topRow][lightLineLeftPad+i] = '●'
        		}

        		// compute countdown string (centered vertically)
        		now := time.Now().In(location)
        		christmas := time.Date(2025, time.December, 25, 0, 0, 0, 0, location)
        		if now.After(christmas) {
        			// if past 2025 Christmas, compute next year's
        			christmas = time.Date(now.Year()+1, time.December, 25, 0, 0, 0, 0, location)
        		}
        		duration := christmas.Sub(now)
        		days := int(duration.Hours()) / 24
        		hours := int(duration.Hours()) % 24
        		minutes := int(duration.Minutes()) % 60
        		seconds := int(duration.Seconds()) % 60

        		countdown := fmt.Sprintf("🎅 Christmas Countdown 🎄 %d days %02d hours %02d mins %02d seconds 🎁", days, hours, minutes, seconds)
        		// center countdown horizontally and vertically (place around middle)
        		countdownRunes := []rune(countdown)
        		countdownPad := (cols - len(countdownRunes)) / 2
        		if countdownPad < 0 {
        			countdownPad = 0
        		}
        		countdownRow := rows / 2
        		for i, r := range countdownRunes {
        			if countdownPad+i < cols {
        				canvas[countdownRow][countdownPad+i] = r
        			}
        		}

        		// place bottom lights markers on last row
        		//bottomRow := rows - 1
        		//for i := 0; i < visibleLen && (lightLineLeftPad+i) < cols; i++ {
        		//	canvas[bottomRow][lightLineLeftPad+i] = '●'
        		//}

        		// Render: clear screen, then write lines.
        		// For the two light rows we will print the coloredLights string (which includes trailing spaces),
        		// but it needs to be padded to the left for centering.
        		clearScreen()

        		// top lights: print left padding spaces then colored lights
        		//fmt.Print(strings.Repeat(" ", lightLineLeftPad))
        		//fmt.Print(coloredLights)
        		//fmt.Print(resetSeq)
        		//fmt.Print("\n")

        		// rows between top lights and countdownRow
        		for r := 1; r < countdownRow; r++ {
        			fmt.Print(string(canvas[r]))
        			fmt.Print("\n")
        		}

        		// countdown row - we already put runes into canvas, but countdown line should override with default color
        		// Print line but ensure it's centered the same
        		// To avoid double printing the runes we will directly print the runes on that row
        		fmt.Print(string(canvas[countdownRow]))
        		fmt.Print("\n")

        		// remaining rows until bottomRow-1
        		bottomRow := rows - 1
        		for r := countdownRow + 1; r < bottomRow; r++ {
        			fmt.Print(string(canvas[r]))
        			fmt.Print("\n")
        		}

        		// bottom lights: same as top
        		//fmt.Print(strings.Repeat(" ", lightLineLeftPad))
        		fmt.Print(coloredLights)
        		fmt.Print(resetSeq)
        		fmt.Print("\n")

        		// Move lights offset for rotation
        		offset = (offset + 1) % len(pattern)

        		// update snow: move each flake down by 1; random horizontal drift
        		for i := range flakes {
        			f := &flakes[i]
        			// chance to change drift occasionally
        			if rand.Intn(6) == 0 {
        				f.drift = rand.Intn(3) - 1
        			}
        			f.x += f.drift
        			f.y += 1
        			// wrap or respawn at top if past bottom
        			if f.y >= rows {
        				f.y = 0
        				f.x = rand.Intn(cols)
        				f.drift = rand.Intn(3) - 1
        			}
        			if f.x < 0 {
        				f.x = 0
        			}
        			if f.x >= cols {
        				f.x = cols - 1
        			}
        		}

        		// Wait for next tick
        		<-ticker.C
        	}
        }

        func cleanupAndExit() {
        	showCursor()
        	resetColor()
        	clearScreen()
        	os.Exit(0)
        }
      '';
    };

    nativeBuildInputs = [pkgs.go];

    buildPhase = ''
      runHook preBuild

      # Use embedded Go source
      cp "$src/xmas_countdown_timer.go" .
      cat > go.mod << 'EOF'
      module christmas

      go 1.25.3
      EOF

      # Ensure Go can write caches in the sandbox
      export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
      export GOCACHE="$TMPDIR/go-cache"
      export GOPATH="$TMPDIR/go"
      export GO111MODULE=on
      export GOFLAGS="-buildvcs=false"
      mkdir -p "$XDG_CACHE_HOME" "$GOCACHE" "$GOPATH"

      go build -o xmas-timer .

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp xmas-timer "$out/bin/"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Animated terminal Christmas countdown with snowfall for NixOS/Home Manager";
      license = licenses.mit;
      mainProgram = "xmas-timer";
      platforms = platforms.linux;
    };
  };
in {
  home.packages = [xmasTimer];
}
