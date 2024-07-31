import SwiftUI

struct ContentView: View {
    
    // We store the names in an array of strings
    @State private var names = [""]
    // When this is true, we can enter the next View (all the names have been added)
    @State private var navigateToEnterFood = false

    var body: some View {
        
        NavigationStack {
            
            VStack {
            
                Text("Enter Names: ").fontWeight(.bold).padding()
                
                // ScrollView makes it easy for the user to add as many names as possible inuitively
                
                ScrollView {
                    VStack {
                        // Uses a for loop to dynamically print 'Person (index + 1)'s' name
                        ForEach(0..<names.count, id: \.self) { index in
                            TextField("Person \(index+1) name", text: $names[index])
                                .padding(.vertical, 5)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    HStack {
                        // calls addName function, which increases the name array by 1 (and updates the for loop above)
                        Button(action: addName) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                                .padding()
                        }
                        
                        // calls the removeName function, which removes the lazst person
                        Button(action: removeName) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                .padding()
                
                // When the "Next Page: Enter Food" button is hit, the user is directed to the next page and the bool is true.
                Button(action: {
                    navigateToEnterFood = true
                }) {
                    Text("Next Page: Enter Food")
                
                }
                .padding()
            }
            
            // the names array is passed as this will be needed for calculations later
            .navigationDestination(isPresented: $navigateToEnterFood) {
                FoodView(names: $names)
            }
        }
    }

    func addName() {
        names.append("")
    }

    func removeName() {
        if names.count > 1 {
            names.removeLast()
        }
    }
}



struct FoodView: View {
    
    // Takes the names variable from previous View
    @Binding var names: [String]
    
    // Initialises foods, prices array, along with food and prices dictionary

    @State private var foods = [""]
    @State private var prices = [""]
    @State private var food_price_dict = [String: String]()
    
    // Will trigger next View
    @State private var navigateToWhoAteWhat = false

    var body: some View {
        VStack {
            Text("Enter Food: ").fontWeight(.bold).padding()
            
            // This generally follows a similar structure to the previous view, except the item and price are on one HStack (so they are the same row)

            ScrollView {
                VStack {
                    ForEach(0..<foods.count, id: \.self) { index in
                        HStack {
                            TextField("Item \(index+1) name", text: $foods[index])
                                .padding(.vertical, 5)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .listStyle(PlainListStyle())

                            TextField("Price", text: $prices[index])
                                .padding(.vertical, 5)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .listStyle(PlainListStyle())
                        }
                    }

                    HStack {
                        Button(action: addFood) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                                .padding()
                        }

                        Button(action: removeFood) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    Button(action: {
                        generateFoodPriceDict()
                        navigateToWhoAteWhat = true
                    }) {
                        Text("Next Page: Who Ate What?")
                    }
                    .padding()
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToWhoAteWhat) {
                WhoAteWhat(names: $names, foods: $foods, prices: $prices, food_price_dict: $food_price_dict)
            }
        }
    }
    
    
    func addFood() {
        foods.append("")
        prices.append("")
    }

    func removeFood() {
        if foods.count > 1 && prices.count > 1 {
            foods.removeLast()
            prices.removeLast()
        }
    }
    
    // Generates the dictionary between foods and prices.
    // I didn't directly map it since it was easier to print food and the corresponding prices by storing both in a list (used in the next View).
    func generateFoodPriceDict() {
        food_price_dict = Dictionary(uniqueKeysWithValues: zip(foods, prices))
    }
}

// "Who Ate What" lets the user itemise the food.

struct WhoAteWhat: View {
    
    // Previous variables that have been passed through
    @Binding var names: [String]
    @Binding var foods: [String]
    @Binding var prices: [String]
    @Binding var food_price_dict: [String: String]
    
    // WAW = who ate what, stores each a dictionary mapping each person to a list of all they ate.
    @State private var waw_dict = [String: [String]]()
    // selectionDict maps the food to a dictionary, that maps (person: whether they ate the food or not)
    @State private var selectionDict = [String: [String: Bool]]()
    @State private var navigateToCostPerPerson = false

    var body: some View {
        VStack {
            Text("Who ate what?").fontWeight(.bold).padding()

            ScrollView {
                VStack {
                    ForEach(0..<foods.count, id: \.self) { foodIndex in
                        VStack {
                            
                            // Prints the food and the price of the food by indexing the lists
                            HStack {
                                Text(foods[foodIndex])
                                    .font(.headline)
                                Spacer()
                                Text(prices[foodIndex])
                            }
                            .padding()

                            VStack {
                                ForEach(0..<names.count, id: \.self) { nameIndex in
                                    // Toggle lets the user use a simple button to indicate whether or not they ate the food
                                    Toggle(isOn: Binding<Bool>(
                                        get: {
                                            // Access the dictionary for the current food or an empty dictionary if it doesn't exist
                                            // Then, access the boolean value for the current person or return false if it doesn't exist
                                            selectionDict[foods[foodIndex], default: [:]][names[nameIndex], default: false]
                                        },
                                        // Update the value in selectionDict
                                        set: { newValue in
                                            if selectionDict[foods[foodIndex]] == nil {
                                                selectionDict[foods[foodIndex]] = [names[nameIndex]: newValue]
                                            } else {
                                                selectionDict[foods[foodIndex]]?[names[nameIndex]] = newValue
                                            }
                                        }
                                    )) {
                                        // Displays name next to the Toggle
                                        Text(names[nameIndex])
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .padding()

            Button(action: {
                confirmSelections()
                navigateToCostPerPerson = true
            }) {
                Text("Confirm")
            }
            .padding()

            .navigationDestination(isPresented: $navigateToCostPerPerson) {
                CostPerPersonView(waw_dict: $waw_dict, food_price_dict: $food_price_dict)
            }
        }
    }

    func confirmSelections() {
        
        // This will generate the waw dict, used in the next View
        
        for (food, peopleDict) in selectionDict {
            for (person, isSelected) in peopleDict {
                
                if isSelected {
                    if waw_dict[food] != nil {
                        waw_dict[food]?.append(person)
                    } else {
                        waw_dict[food] = [person]
                    }
                }
            }
        }
    }
}

struct CostPerPersonView: View {
    @Binding var waw_dict: [String: [String]]
    @Binding var food_price_dict: [String: String]
    
    // The cost_per_head dictionary maps the cost from person to their share
    @State private var cost_per_head = [String: Float]()

    var body: some View {
        VStack {
    
            ScrollView {
                
                // Prints everyon'es share
                VStack(alignment: .leading) {
                   
                    Text("Costs per Person:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ForEach(Array(cost_per_head.keys), id: \.self) { key in
                        Text("\(key): \(String(format: "%.2f", cost_per_head[key]!))")
                            .padding(.vertical, 5)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .listStyle(PlainListStyle())
                    }
                }
            }
            .padding()
            .onAppear {
                calculateCostPerPerson()
            }
        }
    }
    
    
    // The cost algorithm works by dividing the food price by how many people ate it, and adding that per food cost to each person who shared it.
    
    func calculateCostPerPerson() {
        var costDict = [String: Float]()
        
        for (food, people) in waw_dict {
            if let priceString = food_price_dict[food], let price = Float(priceString) {
                let costPerPerson = price / Float(people.count)
                for person in people {
                    costDict[person, default: 0] += costPerPerson
                }
            }
        }
        
        cost_per_head = costDict
    }
    
}

// Commented out, but the Preview helps see how the app looks and works

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
