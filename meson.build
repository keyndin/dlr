# project name and programming language
    project('com.github.keyndin.dlr', 'vala', 'c')

	glade_catalog = ''

    # Create a new executable, list the files we want to compile, list the dependencies we need, and install
    executable(
        meson.project_name(),
        'src/Application.vala',
        'src/DLF.vala',
        'src/Station.vala',
        dependencies: [
            dependency('gtk+-3.0'),
        ],
        install: true
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

    #Install our UI file
    install_data(
        join_paths('data', meson.project_name() + '.main.ui'),
        install_dir: glade_catalog
    )

    #Install our style sheet
    install_data(
        join_paths('data', meson.project_name() + '.main.ui.css'),
        install_dir: glade_catalog
    )


    