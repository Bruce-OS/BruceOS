package tui

import (
	"fmt"
	"os"
	"runtime"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type AIModel struct {
	wantAI    bool
	cursor    int // 0 = Yes, 1 = No
	gpuInfo   string
	ramGB     int
	recommend string
	width     int
	height    int
}

func NewAIModel() AIModel {
	m := AIModel{}
	m.detectHardware()
	return m
}

func (m *AIModel) detectHardware() {
	// Detect RAM
	var memStat runtime.MemStats
	runtime.ReadMemStats(&memStat)

	// Fallback: read from /proc/meminfo
	m.ramGB = 0
	data, err := os.ReadFile("/proc/meminfo")
	if err == nil {
		for _, line := range strings.Split(string(data), "\n") {
			if strings.HasPrefix(line, "MemTotal:") {
				var kb int
				fmt.Sscanf(line, "MemTotal: %d kB", &kb)
				m.ramGB = kb / 1024 / 1024
				break
			}
		}
	}

	// Simple GPU detection placeholder
	m.gpuInfo = "Unknown GPU"
	if _, err := os.Stat("/dev/nvidia0"); err == nil {
		m.gpuInfo = "NVIDIA GPU detected"
	} else if _, err := os.Stat("/dev/dri/renderD128"); err == nil {
		m.gpuInfo = "GPU detected (AMD/Intel)"
	}

	// Recommend model based on RAM
	switch {
	case m.ramGB >= 32:
		m.recommend = "llama3:70b (you have plenty of RAM)"
	case m.ramGB >= 16:
		m.recommend = "llama3:8b (good balance for your system)"
	case m.ramGB >= 8:
		m.recommend = "phi3:mini (lightweight, fits your RAM)"
	default:
		m.recommend = "tinyllama (minimal RAM detected)"
	}
}

func (m AIModel) WantAI() bool {
	return m.cursor == 0
}

func (m AIModel) RecommendedModel() string {
	return m.recommend
}

func (m AIModel) Init() tea.Cmd {
	return nil
}

func (m AIModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < 1 {
				m.cursor++
			}
		case "enter":
			return m, func() tea.Msg { return NextScreenMsg{} }
		case "backspace", "b":
			return m, func() tea.Msg { return PrevScreenMsg{} }
		case "q", "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m AIModel) View() string {
	var b strings.Builder

	b.WriteString(TitleStyle.Render("Local AI Setup"))
	b.WriteString("\n")
	b.WriteString(SubtitleStyle.Render("Run AI models locally with Ollama"))
	b.WriteString("\n\n")

	// Hardware info
	b.WriteString(DimStyle.Render(fmt.Sprintf("  Hardware: %s • %d GB RAM", m.gpuInfo, m.ramGB)))
	b.WriteString("\n")
	b.WriteString(DimStyle.Render(fmt.Sprintf("  Recommended: %s", m.recommend)))
	b.WriteString("\n\n")

	b.WriteString(UnselectedStyle.Render("Would you like to set up local AI?"))
	b.WriteString("\n\n")

	options := []string{"Yes — install Ollama and download a model", "No — skip AI setup for now"}
	for i, opt := range options {
		cursor := "  "
		style := UnselectedStyle
		if i == m.cursor {
			cursor = SelectedStyle.Render("> ")
			style = SelectedStyle
		}
		b.WriteString(fmt.Sprintf("%s%s\n", cursor, style.Render(opt)))
	}

	b.WriteString("\n")
	b.WriteString(HelpStyle.Render("↑/↓ navigate • Enter select • b back • q quit"))

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		b.String(),
	)
}
