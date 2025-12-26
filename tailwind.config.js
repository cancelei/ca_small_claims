'use strict';

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class', "[data-theme='dark']"],
  content: [
    './app/views/**/*.{erb,html}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,ts}',
    './app/components/**/*.{erb,rb}'
  ],
  theme: {
    container: {
      center: true,
      padding: '1rem',
      screens: {
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1440px'
      }
    },
    extend: {
      colors: {
        background: 'rgb(var(--background) / <alpha-value>)',
        foreground: 'rgb(var(--foreground) / <alpha-value>)',
        card: {
          DEFAULT: 'rgb(var(--card) / <alpha-value>)',
          foreground: 'rgb(var(--card-foreground) / <alpha-value>)'
        },
        muted: {
          DEFAULT: 'rgb(var(--muted) / <alpha-value>)',
          foreground: 'rgb(var(--muted-foreground) / <alpha-value>)'
        },
        border: 'rgb(var(--border) / <alpha-value>)',
        input: 'rgb(var(--input) / <alpha-value>)',
        ring: 'rgb(var(--ring) / <alpha-value>)',
        primary: {
          DEFAULT: 'rgb(var(--primary) / <alpha-value>)',
          foreground: 'rgb(var(--primary-foreground) / <alpha-value>)'
        },
        secondary: {
          DEFAULT: 'rgb(var(--secondary) / <alpha-value>)',
          foreground: 'rgb(var(--secondary-foreground) / <alpha-value>)'
        },
        accent: {
          DEFAULT: 'rgb(var(--accent) / <alpha-value>)',
          foreground: 'rgb(var(--accent-foreground) / <alpha-value>)'
        },
        success: 'rgb(var(--success) / <alpha-value>)',
        warning: 'rgb(var(--warning) / <alpha-value>)',
        destructive: 'rgb(var(--destructive) / <alpha-value>)',
        info: 'rgb(var(--info) / <alpha-value>)'
      },
      borderRadius: {
        'lg': '0.5rem',
        'xl': '0.75rem',
        '2xl': '1rem',
        '3xl': '1.5rem'
      },
      boxShadow: {
        1: '0 1px 2px rgb(0 0 0 / 0.06)',
        2: '0 4px 10px rgb(0 0 0 / 0.08)',
        3: '0 10px 25px rgb(0 0 0 / 0.10)'
      },
      fontFamily: {
        sans: ['var(--font-sans)'],
        display: ['var(--font-display)'],
        mono: ['var(--font-mono)']
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('daisyui')
  ],
  daisyui: {
    themes: [
      // Custom theme for CA Small Claims (professional/legal)
      {
        claims: {
          'primary': '#2563eb',          // Blue - trust & professionalism
          'primary-content': '#ffffff',
          'secondary': '#7c3aed',         // Violet - authority
          'secondary-content': '#ffffff',
          'accent': '#f59e0b',            // Amber - attention
          'accent-content': '#ffffff',
          'neutral': '#374151',
          'neutral-content': '#ffffff',
          'base-100': '#ffffff',
          'base-200': '#f9fafb',
          'base-300': '#f3f4f6',
          'base-content': '#1f2937',
          'info': '#0ea5e9',
          'info-content': '#ffffff',
          'success': '#10b981',
          'success-content': '#ffffff',
          'warning': '#f59e0b',
          'warning-content': '#ffffff',
          'error': '#ef4444',
          'error-content': '#ffffff'
        }
      },
      // Light themes (5)
      'light',
      'cupcake',
      'emerald',
      'corporate',
      'garden',
      // Dark themes (5)
      'dark',
      'night',
      'dracula',
      'business',
      'forest'
    ],
    darkTheme: 'dark',
    base: true,
    styled: true,
    utils: true,
    prefix: '',
    logs: false,
    themeRoot: ':root'
  }
};
