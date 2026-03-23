package tui

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Messages for screen navigation
type NextScreenMsg struct{}
type PrevScreenMsg struct{}

// Screen identifiers
const (
	ScreenWelcome = iota
	ScreenProfile
	ScreenShell
	ScreenAI
	ScreenSummary
	ScreenApply
	ScreenDone
)

// App is the top-level model that manages screen transitions.
type App struct {
	screen  int
	welcome WelcomeModel
	profile ProfileModel
	shell   ShellModel
	ai      AIModel
	summary SummaryModel
	apply   ApplyModel
	done    DoneModel
	width   int
	height  int
}

func NewApp() App {
	return App{
		screen:  ScreenWelcome,
		welcome: NewWelcomeModel(),
		profile: NewProfileModel(),
		shell:   NewShellModel(),
		ai:      NewAIModel(),
		summary: NewSummaryModel(),
		apply:   NewApplyModel(),
		done:    NewDoneModel(),
	}
}

func (a App) Init() tea.Cmd {
	return nil
}

func (a App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	// Handle window resize globally
	if ws, ok := msg.(tea.WindowSizeMsg); ok {
		a.width = ws.Width
		a.height = ws.Height
	}

	// Handle screen transitions
	switch msg.(type) {
	case NextScreenMsg:
		return a.nextScreen()
	case PrevScreenMsg:
		return a.prevScreen()
	}

	// Delegate to current screen
	var cmd tea.Cmd
	switch a.screen {
	case ScreenWelcome:
		var m tea.Model
		m, cmd = a.welcome.Update(msg)
		a.welcome = m.(WelcomeModel)
	case ScreenProfile:
		var m tea.Model
		m, cmd = a.profile.Update(msg)
		a.profile = m.(ProfileModel)
	case ScreenShell:
		var m tea.Model
		m, cmd = a.shell.Update(msg)
		a.shell = m.(ShellModel)
	case ScreenAI:
		var m tea.Model
		m, cmd = a.ai.Update(msg)
		a.ai = m.(AIModel)
	case ScreenSummary:
		var m tea.Model
		m, cmd = a.summary.Update(msg)
		a.summary = m.(SummaryModel)
	case ScreenApply:
		var m tea.Model
		m, cmd = a.apply.Update(msg)
		a.apply = m.(ApplyModel)
	case ScreenDone:
		var m tea.Model
		m, cmd = a.done.Update(msg)
		a.done = m.(DoneModel)
	}
	return a, cmd
}

func (a App) View() string {
	switch a.screen {
	case ScreenWelcome:
		return a.welcome.View()
	case ScreenProfile:
		return a.profile.View()
	case ScreenShell:
		return a.shell.View()
	case ScreenAI:
		return a.ai.View()
	case ScreenSummary:
		return a.summary.View()
	case ScreenApply:
		return a.apply.View()
	case ScreenDone:
		return a.done.View()
	}
	return ""
}

func (a App) nextScreen() (tea.Model, tea.Cmd) {
	switch a.screen {
	case ScreenWelcome:
		a.screen = ScreenProfile
	case ScreenProfile:
		a.screen = ScreenShell
	case ScreenShell:
		a.screen = ScreenAI
	case ScreenAI:
		// Populate summary with choices
		a.summary.SetChoices(
			a.profile.Selected().Name,
			a.shell.Selected().Name,
			a.ai.WantAI(),
			a.ai.RecommendedModel(),
		)
		a.screen = ScreenSummary
	case ScreenSummary:
		// Set up apply steps based on choices
		a.apply.SetSteps(
			a.profile.Selected().Name,
			a.shell.Selected().Name,
			a.ai.WantAI(),
		)
		a.screen = ScreenApply
		return a, a.apply.Init()
	case ScreenApply:
		a.screen = ScreenDone
	}

	// Forward window size to new screen
	sizeMsg := tea.WindowSizeMsg{Width: a.width, Height: a.height}
	return a.Update(sizeMsg)
}

func (a App) prevScreen() (tea.Model, tea.Cmd) {
	switch a.screen {
	case ScreenProfile:
		a.screen = ScreenWelcome
	case ScreenShell:
		a.screen = ScreenProfile
	case ScreenAI:
		a.screen = ScreenShell
	case ScreenSummary:
		a.screen = ScreenAI
	}

	sizeMsg := tea.WindowSizeMsg{Width: a.width, Height: a.height}
	return a.Update(sizeMsg)
}

// DoneModel is the final screen.
type DoneModel struct {
	width  int
	height int
}

func NewDoneModel() DoneModel {
	return DoneModel{}
}

func (m DoneModel) Init() tea.Cmd {
	return nil
}

func (m DoneModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "enter", "q", "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m DoneModel) View() string {
	content := TitleStyle.Render("BruceOS is ready. Enjoy.") + "\n\n" +
		CheckStyle.Render("✓") + " " + SubtitleStyle.Render("All configuration applied successfully.") + "\n\n" +
		HelpStyle.Render("Press Enter or q to exit")

	box := BoxStyle.Width(50).Render(content)

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		box,
	)
}
