package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Shell struct {
	Name        string
	Description string
	Recommended bool
}

var shells = []Shell{
	{
		Name:        "Fish",
		Description: "Modern, zero-config shell with autosuggestions and syntax highlighting",
		Recommended: true,
	},
	{
		Name:        "Bash",
		Description: "Classic Unix shell — maximum compatibility, minimal magic",
		Recommended: false,
	},
}

type ShellModel struct {
	cursor int
	width  int
	height int
}

func NewShellModel() ShellModel {
	return ShellModel{}
}

func (m ShellModel) Init() tea.Cmd {
	return nil
}

func (m ShellModel) Selected() Shell {
	return shells[m.cursor]
}

func (m ShellModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
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
			if m.cursor < len(shells)-1 {
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

func (m ShellModel) View() string {
	var b strings.Builder

	b.WriteString(TitleStyle.Render("Choose Your Shell"))
	b.WriteString("\n")
	b.WriteString(SubtitleStyle.Render("Pick your default interactive shell"))
	b.WriteString("\n\n")

	for i, s := range shells {
		cursor := "  "
		nameStyle := UnselectedStyle
		if i == m.cursor {
			cursor = SelectedStyle.Render("> ")
			nameStyle = SelectedStyle
		}

		label := s.Name
		if s.Recommended {
			label += " " + CheckStyle.Render("(recommended)")
		}

		b.WriteString(fmt.Sprintf("%s%s\n", cursor, nameStyle.Render(label)))
		b.WriteString(DescriptionStyle.Render(s.Description))
		b.WriteString("\n\n")
	}

	b.WriteString(HelpStyle.Render("↑/↓ navigate • Enter select • b back • q quit"))

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		b.String(),
	)
}
