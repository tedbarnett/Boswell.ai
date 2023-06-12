//
//  APIManager.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import UIKit
import AVFAudio

class APIManager: NSObject {
    static let shared = APIManager()

    var openAI_APIKey: String = {
        guard let plistPath = Bundle.main.path(forResource: "API_Keys_gitignored", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let apiKey = plistDict["OpenAI_API_Key"] as? String, apiKey != "" else {
            if let apiKeyFromLocal = UserDefaultsManager.getOpenAIAPIKey(), apiKeyFromLocal != "" {
                return apiKeyFromLocal
            }
            else {
                return ""
            }
        }
        return apiKey
    }()
    
    var elevenLabAPIKey: String = {
        guard let plistPath = Bundle.main.path(forResource: "API_Keys_gitignored", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let apiKey = plistDict["ELEVEN_LABS_API_KEY"] as? String, apiKey != "" else {
            return ""
        }
        return apiKey
    }()
    
    var elevenLabVoiceId: String = {
        guard let plistPath = Bundle.main.path(forResource: "API_Keys_gitignored", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let apiKey = plistDict["ELEVEN_LABS_VOICE_ID"] as? String, apiKey != "" else {
            return ""
        }
        return apiKey
    }()

    // Sends to OpenAI API, currently using GPT-3 model
    func sendToChatGPT(history: [AIPromptModel], apiModel: BoswellModeModel.APIModel, completion: @escaping ([String: Any]?, Error?) -> Void) -> URLSessionTask {
        var url: URL!
        var requestData: [String: Any] = ["max_tokens": 500, "n": 1, "temperature": 0.5]
        if apiModel == .ChatGPT_4 {
            url = URL(string: GPT_API.CHAT_GPT_4)! //GPT-4
            var prompts: [[String: Any]] = []
            for historyData in history {
                if let content = historyData.content, let role = historyData.role, historyData.isAddToHistory == true {
                    prompts.append(["role": role.rawValue, "content": content])
                }
            }
            requestData["model"] = "gpt-4"
            requestData["messages"] = prompts
        }
        else {
            url = URL(string: GPT_API.GPT_3_5_TURBO)! //gpt-3.5-turbo
            var prompt: String = ""
            for historyData in history {
                if let content = historyData.content, let role = historyData.role,  historyData.isAddToHistory == true {
                    if role == .user || role == .system {
                        prompt.append("You:\(content)\n")
                    }
                    else {
                        prompt.append("AI:\(content)\n\n")
                    }
                }
            }
            prompt.append("AI:\n\n")
            requestData["prompt"] = prompt
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAI_APIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        print("Sending to OpenAI Header:")
        print("Authorization: Bearer \(openAI_APIKey)")
        print("Content-Type: application/json")
        print("Sending to OpenAI: \(requestData)")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20.0
        sessionConfig.timeoutIntervalForResource = 20.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(json, nil)
                    } else {
                        print("Raw response from OpenAI: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")
                        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // Create Image API
    func createImage(text: String, completion: @escaping (UIImage?, Error?) -> Void) -> URLSessionTask {
        let url: URL = URL(string: GPT_API.CREATE_IMAGE)!
        let requestData: [String: Any] = ["prompt": text, "n": 1, "size": "256x256", "response_format": "url"]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAI_APIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        print("Sending to OpenAI: \(requestData)")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20.0
        sessionConfig.timeoutIntervalForResource = 20.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let data = json["data"] as? [[String: Any]], let image = data.first, let url = image["url"] as? String, let imageURL = URL(string: url) {
                            self.getData(from: imageURL) { data, urlResponse, error in
                                if let imageData = data, let image = UIImage(data: imageData) {
                                    completion(image, nil)
                                }
                                else {
                                    completion(nil, nil)
                                }
                            }
                        }
                        else {
                            completion(nil, nil)
                        }
                    } else {
                        print("Raw response from OpenAI: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")
                        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func speakElevenLabs(text: String, completion: @escaping (URL?, Error?) -> Void) {
        let headers = [
            "accept": "audio/x-m4a",
            "xi-api-key": self.elevenLabAPIKey,
            "Content-Type": "application/json"
        ]
        let parameters = [
            "text": text,
            "voice_settings": [
                "stability": 0,
                "similarity_boost": 0
            ]
        ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(self.elevenLabVoiceId)/stream?optimize_streaming_latency=0")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            print("Eleven Lab API:")
            print("Voice Id: \(self.elevenLabVoiceId)")
            print("API Key: \(self.elevenLabAPIKey)")
            print("Sending to Eleven Lab: \(parameters)")
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 20.0
            sessionConfig.timeoutIntervalForResource = 20.0
            let session = URLSession(configuration: sessionConfig)
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(nil, error)
                    } else if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        do {
                            // Save data to a temporary file
                            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempAudio.mp3")
                            // let tempURL = URL("//Users/tedbarnett/Desktop/tempAudio.mp3")
                            try data.write(to: tempURL)
                            print("tempURL is \(tempURL)")
                            completion(tempURL, nil)
                        } catch {
                            print("Error playing audio: \(error)")
                            completion(nil, error)
                        }
                    } else {
                        print("Unexpected response or data is nil")
                        completion(nil, nil)
                    }
                }
            })
            
            dataTask.resume()
        } catch {
            print("Error serializing JSON: \(error)")
            completion(nil, error)
        }
    }
}
