import QtQuick 2.0

Item {
    states: [
        State {
            name: "VISIBLE"
            when: accountList.count === 0
            PropertyChanges {
                target: emptyAccountListPlaceHolder
                visible: true
            }
        },
        State {
            name: "INVISIBLE"
            when: accountList.count > 0
            PropertyChanges {
                target: emptyAccountListPlaceHolder
                visible: false
            }
        }
    ]
    transitions: [
        Transition {
            from: "VISIBLE"; to: "INVISIBLE"
            SequentialAnimation {
                PropertyAnimation {
                    target: emptyAccountListPlaceHolder
                    property: "opacity"
                    from: 1; to: 0
                }
                PropertyAction {
                    property: "visible"
                }
            }
        },
        Transition {
            from: "INVISIBLE"; to: "VISIBLE"
            SequentialAnimation {
                PropertyAction {
                    property: "visible"
                }
                PropertyAnimation {
                    target: emptyAccountListPlaceHolder
                    property: "opacity"
                    from: 0; to: 1
                }
            }
        }
    ]
}
