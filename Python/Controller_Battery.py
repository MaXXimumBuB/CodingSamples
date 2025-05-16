# This code is a widget that monitors the battery power in a video game controller while it is plugged in.

import sys
import hid  
from PyQt6.QtWidgets import QApplication, QWidget, QLabel, QVBoxLayout, QMenu, QColorDialog
from PyQt6.QtCore import Qt, QTimer, QPoint
from PyQt6.QtGui import QFont, QAction

# Function to detect controller and retrieve the connection status, battery level, and charging state
def find_dualsense_status():
    for device in hid.enumerate():
        # Check for known controller vendor and product IDs (wired or wireless)
        if device['vendor_id'] == 0x054C and device['product_id'] in [0x0CE6, 0x0DF2]:
            path = device.get('path', b'').decode(errors='ignore')
            product_string = device.get('product_string', '').lower()

            # Determine if connected via Bluetooth
            # In general, Battery level is not accurate via Bluetooth
            is_bluetooth = ('bth' in path.lower() or 'bluetooth' in product_string or '{00001124-' in path.lower())

            try:
                h = hid.device()
                h.open_path(device['path'])  # Open connection to the device
                h.set_nonblocking(False)
                data = h.read(512, timeout_ms=1000)  # Attempt to read data from controller
                h.close()

                if data:
                    if is_bluetooth:
                        # Battery level isn’t reliable over Bluetooth
                        return "Bluetooth", None, False
                    else:
                        # Found with battery_tester that battery operates on 42 units
                        battery_raw = data[53]
                        battery_percent = None
                        if 0 <= battery_raw <= 42:
                            battery_percent = int((battery_raw / 42) * 100)
                            battery_percent = max(0, min(battery_percent, 100))
                        else:
                            battery_percent = None

                        # Charging status is in byte 54, bit 0
                        charging = bool(data[54] & 0x01)
                        return "Wired", battery_percent, charging
                else:
                    return "Not Connected", None, None
            except Exception as e:
                print(f"Error reading status: {e}")
                return "Not Connected", None, None

    return "Not Connected", None, None

# Class to display the controller status in a floating widget
class ControllerWindow(QWidget):
    def __init__(self):
        super().__init__()

        # Window settings: frameless, always on top, transparent
        self.setWindowTitle("")
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.WindowStaysOnTopHint)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)

        # Default appearance settings
        self.bg_color = "#d4f0fc"
        self.transparent = False

        # Layout and label setup
        self.layout = QVBoxLayout()
        self.layout.setContentsMargins(20, 20, 20, 20)

        self.label = QLabel("Connecting...")
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.setFont(QFont("Arial Rounded MT Bold", 14))
        self.layout.addWidget(self.label)

        self.setLayout(self.layout)
        self.setFixedSize(350, 150)

        # Initial style
        self.setStyleSheet(f"""
            QWidget {{
                background-color: {self.bg_color};
                border-radius: 20px;
            }}
            QLabel {{
                color: #333;
            }}
        """)

        # Set up timer to poll status every 3 seconds
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_status)
        self.timer.start(3000)

        # Track position for drag-and-drop movement
        self.offset = QPoint()

    # Update the label based on the current controller status
    def update_status(self):
        connection_type, battery_percent, charging = find_dualsense_status()

        if connection_type == "Bluetooth":
            text = "🎮 Bluetooth"
            color = "#333333"
        elif connection_type == "Wired":
            if battery_percent is not None:
                if charging:
                    text = f"🎮 Wired | 🔋 Charging ⚡ {battery_percent}%"
                else:
                    text = f"🎮 Wired | 🔋 {battery_percent}%"

                # Set color for battery level
                if battery_percent >= 70:
                    color = "#333333"
                elif battery_percent >= 20:
                    color = "#FFA500"
                else:
                    color = "#F44336"
            else:
                text = "🎮 Wired | 🔋 Unknown"
                color = "#333333"
        else:
            text = "🎮 Not Connected"
            color = "#333333"

        self.label.setText(text)
        self.label.setStyleSheet(f"color: {color};")

    # Enable Dragging
    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.offset = event.pos()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.MouseButton.LeftButton:
            self.move(event.globalPosition().toPoint() - self.offset)

    # Right-click context menu to toggle transparency, color, or exit
    def contextMenuEvent(self, event):
        menu = QMenu(self)

        toggle_action = QAction("Toggle Transparency", self)
        toggle_action.triggered.connect(self.toggle_transparency)
        menu.addAction(toggle_action)

        color_action = QAction("Change Background Color", self)
        color_action.triggered.connect(self.change_color)
        menu.addAction(color_action)

        exit_action = QAction("Exit", self)
        exit_action.triggered.connect(self.close)
        menu.addAction(exit_action)

        menu.setStyleSheet("""
            QMenu {
                background-color: #ffffff;
                color: #000000;
                border: 1px solid #cccccc;
                border-radius: 8px;
                padding: 5px;
            }
            QMenu::item {
                color: #000000;
            }
            QMenu::item:selected {
                background-color: #d4f0fc;
                color: #000000;
            }
        """)

        menu.exec(event.globalPos())

    # Toggle between solid background and full transparency
    def toggle_transparency(self):
        if not self.transparent:
            self.setStyleSheet("""
                QWidget {
                    background-color: transparent;
                }
                QLabel {
                    color: #333;
                }
            """)
            self.transparent = True
        else:
            self.setStyleSheet(f"""
                QWidget {{
                    background-color: {self.bg_color};
                    border-radius: 20px;
                }}
                QLabel {{
                    color: #333;
                }}
            """)
            self.transparent = False

    # Color picker
    def change_color(self):
        color = QColorDialog.getColor()
        if color.isValid():
            self.bg_color = color.name()
            self.setStyleSheet(f"""
                QWidget {{
                    background-color: {self.bg_color};
                    border-radius: 20px;
                }}
                QLabel {{
                    color: #333;
                }}
            """)

# Main
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = ControllerWindow()
    window.show()
    sys.exit(app.exec())
