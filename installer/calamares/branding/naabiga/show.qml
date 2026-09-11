/* Naabiga OS — diaporama d'installation Calamares (slideshowAPI 2) */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }

    Timer {
        interval: 12000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Rectangle { anchors.fill: parent; color: "#111111" }

    Slide {
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8; wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter; color: "#FFFFFF"; font.pixelSize: 26
            text: "<b style='color:#D4AF37'>Naabiga OS</b><br><br>Le premier système d'exploitation conçu par des Burkinabè, pour les Burkinabè et pour l'Afrique.<br><br><span style='color:#BBBBBB;font-size:18px'>Build Faster. Create Smarter.</span>"
        }
    }
    Slide {
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8; wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter; color: "#FFFFFF"; font.pixelSize: 22
            text: "<b style='color:#D62828'>Prêt à coder en 5 minutes</b><br><br>Flutter, Dart, Java 17, Android SDK, Node.js, Python, PHP, Go, Docker, Git et VS Code sont déjà là.<br><br><span style='color:#BBBBBB'>Lancez <b>nos doctor</b> après l'installation.</span>"
        }
    }
    Slide {
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8; wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter; color: "#FFFFFF"; font.pixelSize: 22
            text: "<b style='color:#198754'>N-OS Center et N-OS CLI</b><br><br>Installez IDE, SDK et assistants IA (Claude Code, Gemini CLI, Ollama…) en une commande :<br><br><span style='color:#D4AF37'>nos install android-studio</span> · <span style='color:#D4AF37'>nos sdk use java 17</span> · <span style='color:#D4AF37'>nos ai install claude</span>"
        }
    }
    Slide {
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8; wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter; color: "#FFFFFF"; font.pixelSize: 22
            text: "<b style='color:#D4AF37'>Sûr et rapide par défaut</b><br><br>Pare-feu activé, mises à jour de sécurité automatiques, ZRAM, TRIM, chiffrement du disque en option.<br><br><span style='color:#BBBBBB'>Support long terme (LTS), stabilité de niveau entreprise.</span>"
        }
    }
    Slide {
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8; wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter; color: "#FFFFFF"; font.pixelSize: 22
            text: "<b style='color:#D62828'>Un projet ouvert</b><br><br>Développé par <b>ICONEDOR</b> avec les étudiants de l'<b>Université Aube Nouvelle</b> de Bobo-Dioulasso.<br><br><span style='color:#BBBBBB'>github.com/princebilogocode/naabiga-os</span>"
        }
    }
}
