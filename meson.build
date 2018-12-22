# project name and programming language
project('com.github.keyndin.dlr', 'vala', 'c')

gnome = import('gnome')


dlr_sources = [
    'src/main.vala',
    'src/MainWindow.vala',
    'src/DLF.vala',
    'src/Station.vala'
]

dlr_dependencies = [
    dependency('gtk+-3.0')
]

dlr_sources += gnome.compile_resources(
        'dlr-resources',
        'src/gresource.xml',
        source_dir: 'src'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    dlr_sources,
    vala_args: '--target-glib=2.50',  
    dependencies: dlr_dependencies,
  install: true,
)

#Install our .desktop file so the Applications Menu will see it
install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Install our .appdata.xml file so AppCenter will see it
install_data(
    join_paths('data', meson.project_name() + '.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)
