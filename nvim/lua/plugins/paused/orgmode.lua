return {
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    opts = {
      org_agenda_files = '~/.local/share/orgfiles/**/*',
      org_default_notes_file = '~/.local/share/orgfiles/refile.org',
    },
  }
}
