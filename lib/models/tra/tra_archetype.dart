import 'package:flutter/material.dart';

enum TraArchetype {
  spark(
    number: 1,
    name: 'Spark',
    symbol: '✦',
    description: 'Catalyzes new beginnings, triggers impulse, and initiates emergence.',
    color: Color(0xFFEF4444), // Crimson/Red
    secondaryColor: Color(0xFFF97316), // Orange
  ),
  analyst(
    number: 2,
    name: 'Analyst',
    symbol: '📊',
    description: 'Deconstructs patterns, parses data, and structures raw observation.',
    color: Color(0xFF3B82F6), // Blue
    secondaryColor: Color(0xFF06B6D4), // Cyan
  ),
  connector(
    number: 3,
    name: 'Connector',
    symbol: '🔗',
    description: 'Establishes linkages, bridges nodes, and facilitates relational flow.',
    color: Color(0xFF8B5CF6), // Violet/Purple
    secondaryColor: Color(0xFFEC4899), // Pink
  ),
  visionary(
    number: 4,
    name: 'Visionary',
    symbol: '👁',
    description: 'Projects future horizons, imagines potentiality, and synthesizes long-range pathways.',
    color: Color(0xFFF59E0B), // Amber/Yellow
    secondaryColor: Color(0xFFEAB308), // Yellow
  ),
  hearer(
    number: 5,
    name: 'Hearer',
    symbol: '👂',
    description: 'Absorbs subtle acoustic/cyclical resonance, deepens listening, and gathers inner signal.',
    color: Color(0xFF10B981), // Emerald/Green
    secondaryColor: Color(0xFF06B6D4), // Cyan
  ),
  speaker(
    number: 6,
    name: 'Speaker',
    symbol: '🗣',
    description: 'Articulates structural truth, projects frequency, and broadcasts resonance.',
    color: Color(0xFF3B82F6), // Cobalt Blue
    secondaryColor: Color(0xFF6366F1), // Indigo
  ),
  architect(
    number: 7,
    name: 'Architect',
    symbol: '📐',
    description: 'Designs dimensional frameworks, drafts boundaries, and constructs scaffolding.',
    color: Color(0xFF0EA5E9), // Sky Blue
    secondaryColor: Color(0xFF2563EB), // Blue
  ),
  integrator(
    number: 8,
    name: 'Integrator',
    symbol: '🤝',
    description: 'Harmonizes complex inputs, unites diverse structures, and stabilizes systemic coherence.',
    color: Color(0xFF10B981), // Green
    secondaryColor: Color(0xFF84CC16), // Lime
  ),
  strategist(
    number: 9,
    name: 'Strategist',
    symbol: '🎯',
    description: 'Aligns vectors of movement, targets optimal impact, and plans system execution.',
    color: Color(0xFFF97316), // Dark Orange
    secondaryColor: Color(0xFFDC2626), // Red
  ),
  evaluator(
    number: 10,
    name: 'Evaluator',
    symbol: '🔍',
    description: 'Measures alignment against core templates, audits functionality, and refines quality.',
    color: Color(0xFF64748B), // Slate/Grey
    secondaryColor: Color(0xFF94A3B8), // Light Slate
  ),
  harmonizer(
    number: 11,
    name: 'Harmonizer',
    symbol: '⚖',
    description: 'Balances polarized charges, brings equilibrium, and syncs cyclical waves.',
    color: Color(0xFF14B8A6), // Teal
    secondaryColor: Color(0xFF0EA5E9), // Sky Blue
  ),
  inspirer(
    number: 12,
    name: 'Inspirer',
    symbol: '🔥',
    description: 'Radiates accumulated frequency, elevates systemic spirit, and prepares the next spark.',
    color: Color(0xFFEC4899), // Hot Pink
    secondaryColor: Color(0xFFF43F5E), // Rose
  );

  final int number;
  final String name;
  final String symbol;
  final String description;
  final Color color;
  final Color secondaryColor;

  const TraArchetype({
    required this.number,
    required this.name,
    required this.symbol,
    required this.description,
    required this.color,
    required this.secondaryColor,
  });

  static TraArchetype fromNumber(int num) {
    // num is 1-based, map back to 0-based index
    final index = (num - 1) % values.length;
    return values[index < 0 ? index + values.length : index];
  }
}
