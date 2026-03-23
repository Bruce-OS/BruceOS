package tui

import "github.com/charmbracelet/lipgloss"

// BruceOS brand color
const BrandGreen = "#10b981"

var (
	// Base styles
	TitleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color(BrandGreen)).
			MarginBottom(1)

	SubtitleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#9ca3af")).
			MarginBottom(1)

	SelectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(BrandGreen)).
			Bold(true)

	UnselectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#d1d5db"))

	DescriptionStyle = lipgloss.NewStyle().
				Foreground(lipgloss.Color("#6b7280")).
				PaddingLeft(4)

	HelpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#4b5563")).
			MarginTop(2)

	BoxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color(BrandGreen)).
			Padding(1, 3)

	CheckStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(BrandGreen))

	ErrorStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#ef4444"))

	DimStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#6b7280"))

	SpinnerStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(BrandGreen))
)
