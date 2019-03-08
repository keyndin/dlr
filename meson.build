# project name and programming language
project('com.github.keyndin.dlr', 'vala', 'c')

gnome = import('gnome')


dlr_sources = [
    'src/main.vala',
    'src/MainWindow.vala',
    'src/DLF.vala',
    'src/Nova.vala',
    'src/Kultur.vala',
    'src/A_Station.vala',
    'src/E_StationNames.vala',
    'src/Podcast.vala',
    'src/Broadcast.vala',
    'src/StreamPlayer.vala',

]

dlr_dependencies = [
    dependency('gtk+-3.0'),
    dependency('gstreamer-1.0')
]

dlr_sources += gnome.compile_resources(
        'dlr-resources',
        'src/gresource.xml',
        source_dir: 'src'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    # meson.project_name(),
    'dlr',
    dlr_sources,
    vala_args: [
        '--pkg=gtk+-3.0', 
        '--pkg=gmodule-2.0',
        '--pkg=gstreamer-1.0'
        ],
    dependencies: dlr_dependencies,
    install: true,
    export_dynamic: true
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
