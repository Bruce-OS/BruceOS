package tui

import (
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const asciiLogo = `
    ██████╗
    ██╔══██╗
    ██████╔╝
    ██╔══██╗
    ██████╔╝
    ╚═════╝ `

type WelcomeModel struct {
	width  int
	height int
}

func NewWelcomeModel() WelcomeModel {
	return WelcomeModel{}
}

func (m WelcomeModel) Init() tea.Cmd {
	return nil
}

func (m WelcomeModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "enter", " ", "n":
			return m, func() tea.Msg { return NextScreenMsg{} }
		case "q", "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m WelcomeModel) View() string {
	logoStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color(BrandGreen)).
		Bold(true)

	var b strings.Builder

	b.WriteString(logoStyle.Render(asciiLogo))
	b.WriteString("\n\n")
	b.WriteString(TitleStyle.Render("Welcome to BruceOS"))
	b.WriteString("\n")
	b.WriteString(SubtitleStyle.Render("Your Linux. No nonsense. Just works."))
	b.WriteString("\n\n")
	b.WriteString(DimStyle.Render("This setup wizard will configure your system."))
	b.WriteString("\n")
	b.WriteString(DimStyle.Render("It only takes a minute."))
	b.WriteString("\n\n")
	b.WriteString(HelpStyle.Render("Press Enter to continue • q to quit"))

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		b.String(),
	)
}
