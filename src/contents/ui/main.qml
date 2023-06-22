// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import org.kde.kirigami 2.19 as Kirigami
import org.kde.dfc 1.0
import QmlEV 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("dfc")

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    onClosing: App.saveWindowGeometry(root)

    onWidthChanged: saveWindowGeometryTimer.restart()
    onHeightChanged: saveWindowGeometryTimer.restart()
    onXChanged: saveWindowGeometryTimer.restart()
    onYChanged: saveWindowGeometryTimer.restart()

    Component.onCompleted: App.restoreWindowGeometry(root)

    // This timer allows to batch update the window size change to reduce
    // the io load and also work around the fact that x/y/width/height are
    // changed when loading the page and overwrite the saved geometry from
    // the previous session.
    Timer {
        id: saveWindowGeometryTimer
        interval: 1000
        onTriggered: App.saveWindowGeometry(root)
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("dfc")
        titleIcon: "applications-graphics"
        isMenu: !root.isMobile
        actions: [
            Kirigami.Action {
                text: i18n("Open folder")
                icon.name: "folder"
                onTriggered: {
                   FileIO.open(EnvironmentVariable.value("HOME") + "/.local/share/applications/")
                }
            },
            Kirigami.Action {
                text: i18n("About Desktop Files Creator")
                icon.name: "help-about"
                onTriggered: pageStack.layers.push('qrc:About.qml')
            },
            Kirigami.Action {
                text: i18n("Quit")
                icon.name: "application-exit"
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: page

   Kirigami.ScrollablePage {
    id: page
    Layout.fillWidth: true
    title: "Desktop Files Creator"

    ColumnLayout {
        Kirigami.FormLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            width: page.width

            GridLayout {
                columns: 2
                rows: 3

                Controls.Label {
                    text: "Name:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.TextField {
                    id: name
                    placeholderText: i18n("Application Name")
                }
                Controls.Label {
                    text: "Comment:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.TextField {
                    id: comment
                    placeholderText: i18n("Comment")
                }
                Controls.Label {
                    text: "Categories:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.TextField {
                    id: categories
                    placeholderText: i18n("Application Categories")
                }
             }

             GridLayout {
                columns: 3
                rows: 2

                Controls.Label {
                    text: "Icon:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.TextField {
                   id: icon
                   placeholderText: i18n("Application Icon Path")
                }
                Controls.Button {
                   icon.name: "folder"
                   onClicked: iconFileDialog.open()
                }
                Controls.Label {
                    text: "Exec:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.TextField {
                    id: exec
                    placeholderText: i18n("Path to the executable file")
                }
                Controls.Button {
                    icon.name: "folder"
                    onClicked: execFileDialog.open()
                }
            }

            Controls.CheckBox {
                id: displayCheckBox
                text: "Don't show in menu"
            }

            Controls.CheckBox {
                id: terminalCheckBox
                text: "Run in terminal"
            }

            Controls.Button {
                text: i18n("Create")
                onClicked: {
                  if (name.text.length === 0){
                      showPassiveNotification("Enter application name")
                      name.focus = true
                      return;
               }
               question.open()
            }
         }
      }

       Kirigami.PromptDialog {
          id: alert
          standardButtons: Kirigami.Dialog.Ok
      }

       Kirigami.PromptDialog {
          id: question
          title: "Question"
          subtitle: "Create file "+name.text+".desktop?"
          standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
          onAccepted: createDesktopFile()
        }
      }

      FileDialog {
         id: iconFileDialog
         title: "Please select an icon"
         folder: shortcuts.home
         nameFilters: [ "Image files (*.png *.jpg *.svg)", "All files (*)" ]
         selectedNameFilter: "All files (*)"
         onAccepted: {
            icon.text = FileIO.toPath(iconFileDialog.fileUrl)
       }
     }

     FileDialog {
         id: execFileDialog
         title: "Select executable file"
         folder: shortcuts.home
         onAccepted: {
            exec.text = FileIO.toPath(execFileDialog.fileUrl)
       }
     }
   }

   function createDesktopFile(){
       var path = EnvironmentVariable.value("HOME") + "/.local/share/applications/";

       if(!FileIO.exists(path)){
           showAlert("Attention!", "Path "+path+" does not exist! The program will not be able to perform its functions.")
           return;
       }

       var filePath = path + name.text + ".desktop"

       if(FileIO.exists(filePath)){
           showAlert("Attention!", "A file with the same name already exists")
           return;
       }

       var display;
       var terminal;

       if(displayCheckBox.checked){
           display = "true"
       }else{
           display = "false"
       }
       if(terminalCheckBox.checked){
           terminal = "true"
       }else{
           terminal = "false"
       }

       var desktopFile="[Desktop Entry]
Encoding=UTF-8
Type=Application
NoDisplay="+display+"
Terminal="+terminal+"
Exec="+exec.text+"
Icon="+icon.text+"
Name="+name.text+"
Comment="+comment.text+"
Categories="+categories.text;

      FileIO.save(desktopFile, filePath);

      if(FileIO.exists(filePath)){
          showPassiveNotification("File created successfully")
      }else{
          showPassiveNotification("Failed to create file")
      }
   }

   function showAlert(title, subtitle){
        alert.open()
        alert.title = title
        alert.subtitle = subtitle
   }
}
