package tui

import (
	"fmt"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type applyStep struct {
	name string
	done bool
}

type stepDoneMsg struct{}
type allDoneMsg struct{}

type ApplyModel struct {
	steps    []applyStep
	current  int
	spinner  spinner.Model
	progress progress.Model
	done     bool
	width    int
	height   int
}

func NewApplyModel() ApplyModel {
	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = SpinnerStyle

	p := progress.New(progress.WithDefaultGradient())

	return ApplyModel{
		spinner:  s,
		progress: p,
	}
}

func (m *ApplyModel) SetSteps(profile string, shell string, aiSetup bool) {
	m.steps = []applyStep{
		{name: fmt.Sprintf("Installing %s profile packages", profile)},
		{name: fmt.Sprintf("Setting default shell to %s", shell)},
	}
	if aiSetup {
		m.steps = append(m.steps,
			applyStep{name: "Installing Ollama"},
			applyStep{name: "Downloading AI model"},
		)
	}
	m.steps = append(m.steps, applyStep{name: "Applying system configuration"})
	m.current = 0
	m.done = false
}

func (m ApplyModel) Init() tea.Cmd {
	return tea.Batch(m.spinner.Tick, simulateStep())
}

// simulateStep fakes a step taking some time. Real logic replaces this later.
func simulateStep() tea.Cmd {
	return tea.Tick(800*time.Millisecond, func(time.Time) tea.Msg {
		return stepDoneMsg{}
	})
}

func (m ApplyModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.progress.Width = min(msg.Width-20, 50)

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd

	case stepDoneMsg:
		if m.current < len(m.steps) {
			m.steps[m.current].done = true
			m.current++
		}
		if m.current >= len(m.steps) {
			m.done = true
			return m, func() tea.Msg { return allDoneMsg{} }
		}
		return m, simulateStep()

	case allDoneMsg:
		return m, func() tea.Msg { return NextScreenMsg{} }

	case tea.KeyMsg:
		if msg.String() == "q" || msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m ApplyModel) View() string {
	var b strings.Builder

	b.WriteString(TitleStyle.Render("Applying Configuration"))
	b.WriteString("\n\n")

	for i, step := range m.steps {
		if step.done {
			b.WriteString(fmt.Sprintf("  %s %s\n", CheckStyle.Render("✓"), step.name))
		} else if i == m.current {
			b.WriteString(fmt.Sprintf("  %s %s\n", m.spinner.View(), step.name))
		} else {
			b.WriteString(fmt.Sprintf("  %s %s\n", DimStyle.Render("○"), DimStyle.Render(step.name)))
		}
	}

	b.WriteString("\n")

	pct := 0.0
	if len(m.steps) > 0 {
		pct = float64(m.current) / float64(len(m.steps))
	}
	b.WriteString("  " + m.progress.ViewAs(pct))
	b.WriteString("\n")

	if !m.done {
		b.WriteString(HelpStyle.Render("\n  Please wait..."))
	}

	return lipgloss.Place(
		m.width, m.height,
		lipgloss.Center, lipgloss.Center,
		b.String(),
	)
}
