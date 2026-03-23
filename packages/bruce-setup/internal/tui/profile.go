package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Profile struct {
	Name        string
	Description string
	Packages    string
}

var profiles = []Profile{
	{
		Name:        "Default",
		Description: "Clean desktop with essentials — browser, terminal, office",
		Packages:    "firefox, libreoffice, ghostty, fish",
	},
	{
		Name:        "Gaming",
		Description: "Steam, Proton-GE, MangoHud, GameMode, DXVK",
		Packages:    "steam, proton-ge, mangohud, gamemode",
	},
	{
		Name:        "VFX",
		Description: "Blender, DaVinci Resolve, GIMP, Krita, Distrobox for VFX Reference Platform",
		Packages:    "blender, gimp, krita, distrobox",
	},
	{
		Name:        "Kids",
		Description: "Kid-safe defaults, educational apps, parental controls",
		Packages:    "gcompris, tuxpaint, scratch",
	},
}

type ProfileModel struct {
	cursor int
	width  int
	height int
}

func NewProfileModel() ProfileModel {
	return ProfileModel{}
}

func (m ProfileModel) Init() tea.Cmd {
	return nil
}

func (m ProfileModel) Selected() Profile {
	return profiles[m.cursor]
}

func (m ProfileModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
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
			if m.cursor < len(profiles)-1 {
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

func (m ProfileModel) View() string {
	var b strings.Builder

	b.WriteString(TitleStyle.Render("Choose Your Profile"))
	b.WriteString("\n")
	b.WriteString(SubtitleStyle.Render("Select what kind of setup you need"))
	b.WriteString("\n\n")

	for i, p := range profiles {
		cursor := "  "
		nameStyle := UnselectedStyle
		if i == m.cursor {
			cursor = SelectedStyle.Render("> ")
			nameStyle = SelectedStyle
		}
		b.WriteString(fmt.Sprintf("%s%s\n", cursor, nameStyle.Render(p.Name)))
		b.WriteString(DescriptionStyle.Render(p.Description))
		b.WriteString("\n")
		if i == m.cursor {
			b.WriteString(DescriptionStyle.Render(DimStyle.Render("Packages: "+p.Packages)))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	b.WriteString(HelpStyle.Render("↑/↓ navigate • Enter select • b back • q quit"))

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		b.String(),
	)
}
