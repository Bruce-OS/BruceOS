package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type SummaryModel struct {
	profile  string
	shell    string
	aiSetup  bool
	aiModel  string
	width    int
	height   int
}

func NewSummaryModel() SummaryModel {
	return SummaryModel{}
}

func (m *SummaryModel) SetChoices(profile, shell string, aiSetup bool, aiModel string) {
	m.profile = profile
	m.shell = shell
	m.aiSetup = aiSetup
	m.aiModel = aiModel
}

func (m SummaryModel) Init() tea.Cmd {
	return nil
}

func (m SummaryModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "enter", "y":
			return m, func() tea.Msg { return NextScreenMsg{} }
		case "backspace", "b":
			return m, func() tea.Msg { return PrevScreenMsg{} }
		case "q", "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m SummaryModel) View() string {
	var b strings.Builder

	b.WriteString(TitleStyle.Render("Configuration Summary"))
	b.WriteString("\n\n")

	check := CheckStyle.Render("✓")

	b.WriteString(fmt.Sprintf("  %s  Profile:  %s\n", check, SelectedStyle.Render(m.profile)))
	b.WriteString(fmt.Sprintf("  %s  Shell:    %s\n", check, SelectedStyle.Render(m.shell)))

	if m.aiSetup {
		b.WriteString(fmt.Sprintf("  %s  AI:      %s\n", check, SelectedStyle.Render("Ollama + "+m.aiModel)))
	} else {
		b.WriteString(fmt.Sprintf("  %s  AI:      %s\n", DimStyle.Render("–"), DimStyle.Render("Skipped")))
	}

	b.WriteString("\n\n")
	b.WriteString(SubtitleStyle.Render("Press Enter to apply these settings"))
	b.WriteString("\n")
	b.WriteString(HelpStyle.Render("Enter apply • b back • q quit"))

	content := BoxStyle.Render(b.String())

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		content,
	)
}
