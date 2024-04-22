struct API {
    let system: SystemAPI
    let storage: StorageAPI
    let desktop: DesktopAPI
    let gui: GUIAPI
    let application: ApplicationAPI

    init(
        system: SystemAPI,
        storage: StorageAPI,
        desktop: DesktopAPI,
        gui: GUIAPI,
        application: ApplicationAPI
    ) {
        self.system = system
        self.storage = storage
        self.desktop = desktop
        self.gui = gui
        self.application = application
    }
}
