//
//  GECalculations.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/5/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

public class GEnergyCalculations {
    func test() {
        Log.message(.warning, message: "******* DEBUG MESSAGE FROM XCTest !! *******")
    }


    let feature_references = ["Lighting": "lighting_database", "Combination Oven": "combination_ovens",
                              "Convection Oven": "convection_ovens", "Conveyor Oven": "conveyor_ovens", "Dishwasher": "dishwashers",
                              "Freezer": "freezers", "Fryer": "fryers", "Glass Door Refrigerator": "glass_door_refrig", "Griddle": "griddles",
                              "Hot Food Cabinet": "hfcs", "Ice Maker": "ice_makers", "Pre-Rinser": "pre-rinse", "Rack Oven": "rack_ovens",
                              "Refrigerator": "refrigerators", "Solid Door Freezer": "solid_door_freezers", "Solid Door Refrigerator": "solid_door_refrigerators", "Steam Cooker": "steam_cookers"]



    /* Function: is_energy_star()
    * ---------------------------
    * This method loops through the csv for the kitchen appliance and then checks to see if the model
    * and company can be found in the list. If it is, then you return true saying that it has been found
    * and false if you never found the model in the list.
    */

    func is_energy_star(model_number: String, company: String, file_name: String) -> Bool {
        let rows = open_csv(filename: file_name)

        for row in rows! {

            if row["Company"]! != company {
                continue
            }
            if row["Model Number"]! != model_number { //model_number must be revised. Not sure what it should be, depends on the csv
                continue
            }
            return true

        }

        return false
    }



    /* ----------------------------------------------------------BEGINNING OF THE COMPUTE APPLIANCE SECTION---------------------------------------------------- */


    /*This method is repeated for every single different kitchen appliance. It first checks to see if the model and company
    * can be found in the energy star list. If it is, then the method is complete and the original appliance is the best one.
    * If not, then the "find-best-model" method for that appliance is called with the specific parameters, and the best model is found
    * and then model number is returned.
    */



    /* Griddles */
    private func __compute__griddle(model_number:String, company: String) {
        let energy_star = is_energy_star(model_number: model_number,
                company: company, file_name: feature_references["Convection Oven"]!)

        if energy_star {
            return
        }

        let best_model_num = find_best_model_griddle(
                surface_area: curr_values["size"]!, size: curr_values["capacity"]!,
                nominal_width: curr_values["width"]!, fuel_type: curr_values["fuel_type"]!,
                file_name: feature_references["Griddle"]!
        )
    }


    /* -------------------------------------------------------BEGINNING OF THE "FIND BEST MODEL" APPLIANCE SECTION------------------------------------------------- */


    /* This method opens the csv for the certain kitchen appliance. Then it finds all the models where the fixed parameters all match the original
    * appliance. This will guarantee that the new appliance matches the correct specifications of the original non-energy-star model.
    *
    * To create new find best model method: Change the parameters to the be the parameters that must be held constant in the new model
    * Replace the row[""] with the correct header name in the csv that corresponds to the parameter that must be held constant between models.
    * Then you will need to create a new find_energy_cost for the new appliance with the parameters needed for the energy cost calculations
    */


    /* Griddles */
    private func find_best_model_griddle(surface_area: String, size: String, nominal_width: String, fuel_type: String, file_name: String) -> String{

        let rows = open_csv(filename: file_name)

        var new_dict = Dictionary<String, Double>()

        for row in rows! {

            /*  if row["Header String in the csv"] != parameters_name {
            *           continue
            *   }
            */

            if row["Single or Double Sided"] != size {
                continue
            }
            if row["Surface Area (ft²)"] != surface_area {
                continue
            }
            if row["Nominal Width (ft)"] != nominal_width {
                continue
            }
            if row["Fuel Type"] != fuel_type {
                continue
            }

            //Preheat Energy, Idle Energy Rate
            new_dict[row["Model Number"]!] = find_energy_cost_combination_fryer_griddle(preheat_energy: Double(row["Preheat Energy (Btu)"]!)!,
                    idle_energy_rate: Double(row["Idle Energy Rate (Btu/h or kW)"]!)!)
        }

        var best_model = find_lowest_cost_model(list_of_costs: new_dict)

        return best_model
    }



    private func find_energy_cost_combination_fryer_griddle(preheat_energy: Double, idle_energy_rate: Double) -> Double{

        var pricing_chart = get_bill_data(bill_type: audit.outputs["Rate Structure Electric"]!)

        // ToDo : Verify -- Usage Operation -- didn't we say we wanted UI to grab information regarding usage each day ???

        //Weekly Gas Cost -- This should be calculated over yearly basis *****
        var gas_energy = preheat_energy * Double(audit.outputs["days_in_operation"] as! String)! + Double(audit.outputs["ideal_run_hours"] as! String)! * idle_energy_rate

        var winter_rate = calculate_winter_rate(gas_energy: gas_energy)

        var summer_rate = calculate_summer_rate(gas_energy: gas_energy)


        var gas_cost = gas_energy / 99976.1 * (winter_rate + summer_rate) / 2


        var peak_hour_schedule = calculate_all_peak_hours()

        //Electric Cost Weekly:
        var summer = Double(peak_hour_schedule["Summer-On-Peak"]!) * idle_energy_rate * Double(pricing_chart["Summer-On-Peak"]!)
        summer += Double(peak_hour_schedule["Summer-Part-Peak"]!) * idle_energy_rate * Double(pricing_chart["Summer-Part-Peak"]!)
        summer += Double(peak_hour_schedule["Summer-Off-Peak"]!) * idle_energy_rate * Double(pricing_chart["Summer-Off-Peak"]!)

        var winter = Double(peak_hour_schedule["Winter-On-Peak"]!) * idle_energy_rate * Double(pricing_chart["Winter-On-Peak"]!)
        winter += Double(peak_hour_schedule["Winter-Off-Peak"]!) * idle_energy_rate * Double(pricing_chart["Winter-Off-Peak"]!)

        var total_electric = summer + winter

        var total_cost = total_electric + gas_cost

        return total_cost

    }




    /* Function: get_bill_data()
* --------------------------
* This method walks through the csv to find the rates of each of the peak times. This is based on the
* bill_type.
*/
    private func get_bill_data(bill_type: String) -> Dictionary<String, Double> {


        let rows = open_csv(filename: "pge_electric")

        var new_dict = Dictionary<String, Double>()

        var found = false
        var summer = true
        var super_exists = false

        for row in rows! {

            //This loops until it finds the correct bill_type
            if row["Name"]! == bill_type {
                found = true
            } else if row["Name"]! != bill_type {
                if !found {
                    continue
                } else if !row["Name"]!.isEmpty {
                    break
                }
            }

            //This adds the two winter rates
            if row["Season"]! == "Winter"{
                summer = false
                if row["Peak"]! == "On-Peak" {
                    new_dict["Winter-On-Peak"] = Double(row["Energy"]!)
                } else {
                    new_dict["Winter-Off-Peak"] = Double(row["Energy"]!)
                }

                //This adds the summer rates
            } else if row["Season"]! == "Summer" || summer {
                summer = true
                //If the bill has a super-peak, then this code just makes it On-Peak and shifts everything down one
                if row["Peak"]! == "Super-Peak" || super_exists {
                    super_exists = true
                    if row["Peak"]! == "Super-Peak" {
                        new_dict["Summer-On-Peak"] = Double(row["Energy"]!)
                    } else if row["Peak"] == "On-Peak" {
                        new_dict["Summer-Part-Peak"] = Double(row["Energy"]!)
                    } else {
                        new_dict["Summer-Off-Peak"] = Double(row["Energy"]!)
                    }

                    //otherwise it adds the Peak rates like normal
                } else {
                    if row["Peak"]! == "On-Peak" {
                        new_dict["Summer-On-Peak"] = Double(row["Energy"]!)
                    } else if row["Peak"] == "Part-Peak" {
                        new_dict["Summer-Part-Peak"] = Double(row["Energy"]!)
                    } else {
                        new_dict["Summer-Off-Peak"] = Double(row["Energy"]!)
                    }
                }
            }
        }
        return new_dict
    }



    /* Function: calculate_winter_rate()
* ----------------------------------
* This calculates the winter rate for the gas based on the gas bill. It calculates the daily_energy_usage
* and then uses that to find the correct column for average_daily_usage. Then it adds the winter rate and the
* Public Purpose Program Surcharge.
*/
    private func calculate_winter_rate(gas_energy: Double) -> Double{
        //super estimation, 6 is to make it likely an overestimation
        var daily_energy_usage = gas_energy / 6

        var total_cost = 0.0
        var found = false
        let rows = open_csv_rows(filename: "pge_gas_small")

        var month = 0

        for row in rows! {

            //This loops until the first month is found, it can be adjusted to find the correct first month
            if row[0][0] != "0" && !found {
                continue
            }
            found = true

            var running_month_total = 0.0

            //This finds the correct range for the daily-usage rate
            if daily_energy_usage <= 5.0 {

                running_month_total = Double(row[2])! * 30.0
            } else if daily_energy_usage <= 16.0 {
                running_month_total = Double(row[3])! * 30.0
            } else if daily_energy_usage <= 41.0 {
                running_month_total = Double(row[4])! * 30.0
            } else if daily_energy_usage <= 123.0 {
                running_month_total = Double(row[5])! * 30.0
            } else {
                running_month_total = Double(row[6])! * 30.0
            }

            //This adds the winter_rate
            running_month_total = running_month_total + (daily_energy_usage * 30.0 * Double(row[8])!)

            //This adds the Public Purpose Program Surcharge
            running_month_total = running_month_total + (daily_energy_usage * 30.0 * Double(row[16])!)

            total_cost += running_month_total

            month = month + 1

            if month == 12 {
                break
            }

        }

        //this returns the average to find the monthly cost
        //You can divide by 52 instead in order to make it weekly
        return Double(total_cost / 12)

    }



    /* Function: calculate_summer_rate()
 * ----------------------------------
 * This calculates the winter rate for the gas based on the gas bill. It calculates the daily_energy_usage
 * and then uses that to find the correct column for average_daily_usage. Then it adds the winter rate and the
 * Public Purpose Program Surcharge.
 */
    private func calculate_summer_rate(gas_energy: Double) -> Double {
        //super estimation, 6 is to make it likely an overestimation
        var daily_energy_usage = gas_energy / 6

        var total_cost = 0.0

        let rows = open_csv_rows(filename: "pge_gas_small")
        var found = false
        var month = 0

        for row in rows! {
            //This loops until the first month is found, it can be adjusted to find the correct first month
            if row[0][0] != "0" && !found {
                continue
            }
            found = true

            var running_month_total = 0.0

            if daily_energy_usage <= 5.0 {

                running_month_total = Double(row[2])! * 30.0
            } else if daily_energy_usage <= 16.0 {
                running_month_total = Double(row[3])! * 30.0
            } else if daily_energy_usage <= 41.0 {
                running_month_total = Double(row[4])! * 30.0
            } else if daily_energy_usage <= 123.0 {
                running_month_total = Double(row[5])! * 30.0
            } else {
                running_month_total = Double(row[6])! * 30.0
            }

            //This adds the summer_rate
            running_month_total = running_month_total + (daily_energy_usage * 30.0 * Double(row[10])!)

            running_month_total = running_month_total + (daily_energy_usage * 30.0 * Double(row[16])!)

            total_cost += running_month_total

            month = month + 1

            if month == 12 {
                break
            }

        }

        return Double(total_cost / 12)
    }




    /* Function: calculate_all_peak_hours()
* -------------------------------------
* This takes uses the operating hours, taken from the front-end input. Then it uses those hours
* to calculate how many of the operating hours are in each of the different peaks.
*/

    private func calculate_all_peak_hours() -> Dictionary<String, Int> {
        // ToDo: Verify -- Is this the same as in line - days in operation - ideal run hours
        // ToDo: Verify -- This would be applicable for all the plug load devices i guess

        //This gets the opening and closing hours -- just make sure we get the data on the same hour format that we have used - Military Time
        var opening = audit.outputs["Operating Hours"]?.components(separatedBy: " ")[0]
        var closing = audit.outputs["Operating Hours"]?.components(separatedBy: " ")[1]


        //Current Placeholder, opening_hour will be the first two characters of the "opening" string, same with closing_hour
        var opening_hour = Int("1")
        var closing_hour = Int("2")

        var hour_data = Dictionary<String, Int>()


        //Loops through all 24 hours, could be changed to loop through half-hours
        for i in 1...24 {
            //If the hour i is not within the operating hours, skip it
            if i <= opening_hour! || i > closing_hour! {
                continue
            }

            //Find which Types of peaks this hours fits into
            if i >= 12 && i < 18 {
                hour_data["Summer-On-Peak"]! += 1
            } else if (i >= 8 && i < 12) || (i >= 18 && i < 21){
                hour_data["Summer-Part-Peak"]! += 1
            } else {
                hour_data["Summer-Off-Peak"]! += 1
            }

            if i >= 8 && i < 21 {
                hour_data["Winter-Part-Peak"]! += 1
            } else {
                hour_data["Winter-Off-Peak"]! += 1
            }


        }

        return hour_data

    }


    /* Function: find_lowest_cost_model
* ---------------------------------
* This method loops through all the elements in the map "list_of_costs" and finds the model number
* that has the lowest cost. It also saves the model with the lowest cost in a map to be used to
* calculate the total energy cost for all appliances.
*/

    private func find_lowest_cost_model(list_of_costs: Dictionary<String, Double>) -> String {
        let lowest_cost = 10000000000.0
        var model_name = ""


        for model in list_of_costs.keys {
            if list_of_costs[model]! < lowest_cost {
                model_name = model
            }
        }
        models_to_cost[model_name] = lowest_cost

        return model_name
    }
}
