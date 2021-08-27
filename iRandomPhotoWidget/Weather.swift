//
//  Weather.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 23/8/2021.
//
import Foundation

struct Weather: Codable {
    var place: String
    var value: Int
    var unit: String
}

class WeatherApi : ObservableObject{
    @Published var weather = [Weather]()
    
    func loadData(completion:@escaping ([Weather]) -> ()) {
        
        guard let url = URL(string: "https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=en") else {
            print("Invalid url...")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let recipe = json as? [String: Any] {
                    if let temperature = recipe["temperature"] as? NSDictionary {
                        print(temperature)
                        
                        do{
                            let jsonData = try?  JSONSerialization.data(withJSONObject: temperature["data"]!, options: .prettyPrinted)
                            let result = try JSONDecoder().decode([Weather].self, from: jsonData!)
                            DispatchQueue.main.async {
                                completion(result)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                
            }
        }.resume()
        
    }
}
