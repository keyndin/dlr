icon_sizes = ['32', '48', '64', '128']
# Install our icons
foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

#Install our .desktop file in order for the Applications Menu to see it
install_data(
   join_paths(meson.project_name() + '.desktop'),
   install_dir: join_paths(get_option('datadir'), 'applications')
)

#Install our .appdata.xml file for AppCenter to see it
install_data(
   join_paths(meson.project_name() + '.appdata.xml'),
   install_dir: join_paths(get_option('datadir'), 'metainfo')
)
#Install our gschema.xml
install_data (
    'gschema.xml',
    install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
    rename: meson.project_name () + '.gschema.xml'
)

# Refresh glib schemas
run_command('glib-compile-schemas', '/usr/local/share/glib-2.0/schema')
