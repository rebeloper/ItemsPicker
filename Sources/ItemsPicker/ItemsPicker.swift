//
//  ItemsPicker.swift
//  
//
//  Created by Alex Nagy on 28.10.2022.
//

import SwiftUI

public enum ItemsPickerAlignment {
    case leading, trailing
}

public enum ItemsPickerStyle {
    case automatic, sidebar, insetGrouped, grouped, inset, plain
}

public extension ItemsPicker where Label == EmptyView {
    init(data: Binding<[Item]>,
         selected: Binding<[Item]>,
         alignment: ItemsPickerAlignment = .leading,
         style: ItemsPickerStyle,
         @ViewBuilder cell: @escaping (Item) -> (Cell),
         @ViewBuilder checkedIcon: @escaping () -> CheckedIcon,
         @ViewBuilder uncheckedIcon: @escaping () -> UncheckedIcon) {
        self._data = data
        self._selected = selected
        self.alignment = alignment
        self.style = style
        self.cell = cell
        self.checkedIcon = checkedIcon
        self.uncheckedIcon = uncheckedIcon
        self.label = { EmptyView() }
    }
}

public struct ItemsPicker<Item: Hashable, Cell: View, CheckedIcon: View, UncheckedIcon: View, Label: View>: View {
    
    @Binding public var data: [Item]
    @Binding public var selected: [Item]
    public var alignment: ItemsPickerAlignment
    public var style: ItemsPickerStyle
    @ViewBuilder public var cell: (Item) -> (Cell)
    @ViewBuilder public var checkedIcon: () -> CheckedIcon
    @ViewBuilder public var uncheckedIcon: () -> UncheckedIcon
    @ViewBuilder public var label: () -> Label
    
    @State private var isOn = false
    
    public init(data: Binding<[Item]>,
                selected: Binding<[Item]>,
                alignment: ItemsPickerAlignment = .leading,
                style: ItemsPickerStyle,
                @ViewBuilder cell: @escaping (Item) -> (Cell),
                @ViewBuilder checkedIcon: @escaping () -> CheckedIcon,
                @ViewBuilder uncheckedIcon: @escaping () -> UncheckedIcon,
                @ViewBuilder label: @escaping () -> Label) {
        self._data = data
        self._selected = selected
        self.alignment = alignment
        self.style = style
        self.cell = cell
        self.checkedIcon = checkedIcon
        self.uncheckedIcon = uncheckedIcon
        self.label = label
    }
    
    public var body: some View {
        List {
            Section {
                ForEach(data, id: \.self) { item in
                    Button {
                        if selected.contains(item) {
                            selected.removeAll(where: { $0 == item })
                        } else {
                            selected.append(item)
                        }
                    } label: {
                        HStack {
                            switch alignment {
                            case .leading:
                                if selected.contains(item) {
                                    checkedIcon()
                                } else {
                                    uncheckedIcon()
                                }
                                cell(item)
                            case .trailing:
                                cell(item)
                                Spacer()
                                if selected.contains(item) {
                                    checkedIcon()
                                } else {
                                    uncheckedIcon()
                                }
                            }
                            
                        }
                    }
                }
            } header: {
                HStack {
                    label()
                    Spacer()
                    Toggle("\(isOn ? "Unselect" : "Select") All", isOn: $isOn)
                        .toggleStyle(.button)
                        .buttonStyle(.plain)
                }
            }
            .onChange(of: isOn) { isOn in
                if isOn {
                    selected = data
                } else if selected.count == data.count {
                    selected.removeAll()
                }
            }
            .onChange(of: selected) { selectedItems in
                if selectedItems.count == data.count {
                    isOn = true
                } else if selectedItems.count == data.count - 1 {
                    isOn = false
                }
            }
        }
        .if(style == .automatic, transform: { list in
            list.listStyle(.automatic)
        }).if(style == .sidebar, transform: { list in
            list.listStyle(.sidebar)
        }).if(style == .insetGrouped, transform: { list in
            list.listStyle(.insetGrouped)
        }).if(style == .grouped, transform: { list in
            list.listStyle(.grouped)
        }).if(style == .inset, transform: { list in
            list.listStyle(.inset)
        }).if(style == .plain, transform: { list in
            list.listStyle(.plain)
        })
    }
}


public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

