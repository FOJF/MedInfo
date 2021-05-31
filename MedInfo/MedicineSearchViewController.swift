//
//  ViewController.swift
//  MedInfo
//
//  Created by JJW on 2021/05/20.
//

import UIKit

class MedicineSearchViewController: UIViewController {
    @IBOutlet weak var medicineSearchBar: UISearchBar!
    @IBOutlet weak var medicineListTableView: UITableView!
    @IBOutlet weak var medicineSearchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nothingLabel: UILabel!
    
    var itemNames: [String] = []
    var company: [String] = []
    var data: Data?
    
    let baseURLString = "http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"
    let apiKey = "WLs5zlKIJWWoqmYB%2FhXlXg7oPypz5DMDJEilXG89PQje9V2eDTsBj6KaGNDP1SyygHwuX017G27hPVCqR%2F3lYA%3D%3D"
}

extension MedicineSearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        medicineSearchBar.delegate = self
        medicineListTableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "취소"
        
        view.addGestureRecognizer(tapGesture)
    }
}

//키보드 내리기
extension MedicineSearchViewController {
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

//검색창 옆의 cancel 버튼 클릭시 키보드를 내리고 검색창에 입력했던 내용 지우기
extension MedicineSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

//검색을 했을 경우 api를 통해 json을 받아 적절히 파싱한 후 검색 기록을 출력하거나 결과가 없을 경우 없다고 알림
extension MedicineSearchViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        medicineSearchActivityIndicator.startAnimating() //검색 후 jsonData를 받기 전까지 로딩 중임을 표시
        self.nothingLabel.text = ""
        
        if let searchText = searchBar.text {
            searchBar.resignFirstResponder()
            
            let itemName = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let urlStr = baseURLString + "?" + "serviceKey=" + apiKey + "&" + "itemName=" + itemName + "&" + "type=json"
            let session = URLSession(configuration: .default)
            let url = URL(string: urlStr)
            
            let request = URLRequest(url: url!)
            
            let dataTask = session.dataTask(with: request) {
                (data, response, error) in
                guard let jsonData = data else { print(error!); return}
                if let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                self.data = jsonData
                (self.itemNames, self.company) = self.extractMedicineListData(jsonData: jsonData)
                
                DispatchQueue.main.async { //검색 후 검색결과를 테이블뷰를 다시 로딩해 출력, 검색 중 로딩표시를 멈춤
                    self.medicineListTableView.reloadData()
                    self.medicineSearchActivityIndicator.stopAnimating()
                    
                    if self.itemNames.count == 0 { //검색 결과가 없을 경우 검색결과 없음을 출력
                        self.nothingLabel.text = "검색결과 없음"
                    } else {
                        self.nothingLabel.text = ""
                    }
                }
            }
            dataTask.resume()
        }
    }
}

// 검색한 모든 약들에 대한 모든 정보를 저장하기 위한 json파싱
extension MedicineSearchViewController {
    func extractMedicineData(jsonData: Data, row: Int) -> ([String?]) {
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        var infos: [String?] = []
        
        if let items = (json["body"] as! [String: Any])["items"] { //검색 결과가 없는 경우 body가 없어 죽는 경우 방지
            let itemsNs = items as! NSArray
            
            if let item = (itemsNs[row] as! [String: Any])["itemName"] {
                let itemName = item as? String
                if let range = itemName!.range(of: "(수출명") { //제품명에 수출명이 포함되는 경우 너무 길어지고 불필요한 정보라고 생각되어 제거
                    infos.append(String(itemName!.prefix(itemName!.distance(from: itemName!.startIndex, to: range.lowerBound))))
                } else {
                    infos.append(itemName)
                }
            } else {
                infos.append(nil)
            }
            
            if let entp = (itemsNs[row] as! [String: Any])["entpName"] {
                infos.append(entp as? String)
            } else {
                infos.append(nil)
            }
            
            if let efcyQes = (itemsNs[row] as! [String: Any])["efcyQesitm"] {
                infos.append(efcyQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let useMethodQes = (itemsNs[row] as! [String: Any])["useMethodQesitm"] {
                infos.append(useMethodQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let atpnWarnQes = (itemsNs[row] as! [String: Any])["atpnWarnQesitm"] {
                infos.append(atpnWarnQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let atpnQes = (itemsNs[row] as! [String: Any])["atpnQesitm"] {
                infos.append(atpnQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let intrcQes = (itemsNs[row] as! [String: Any])["intrcQesitm"] {
                infos.append(intrcQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let seQes = (itemsNs[row] as! [String: Any])["seQesitm"] {
                infos.append(seQes as? String)
            } else {
                infos.append(nil)
            }
            
            if let depositMethodQes = (itemsNs[row] as! [String: Any])["depositMethodQesitm"] {
                infos.append(depositMethodQes as? String)
            } else {
                infos.append(nil)
            }
        }
        return infos
    }
}

//검색 후 자세한 정보를 볼 수 있는 제품명들에 대한 정보를 저장하기 위한 json 파싱
extension MedicineSearchViewController {
    func extractMedicineListData(jsonData: Data) -> ([String], [String]) {
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        var names: [String] = []
        var company: [String] = []
        
        if let items = (json["body"] as! [String: Any])["items"] { //검색 결과가 없는 경우 body가 없어 죽는 경우 방지
            let itemsNs = items as! NSArray
            
            for item in itemsNs { //제품명과 제조사명을 데이터에 저장
                var name = (item as! [String: Any])["itemName"] as! String
                
                if let range = name.range(of: "(수출명") { //제품명에 수출명이 포함되는 경우 너무 길어지고 불필요한 정보라고 생각되어 제거
                    name = String(name.prefix(name.distance(from: name.startIndex, to: range.lowerBound)))
                }
                
                if name.count > 20 { //제품명이 너무 길어질 경우 제조사명을 가리게 되기 때문에 적당한 크기로 줄여주고 ...을 붙임
                    names.append(String(name.prefix(20)) + "...")
                } else {
                    names.append(name)
                }
                
                company.append((item as! [String: Any])["entpName"] as! String)
            }
        }
        return (names, company)
    }
}

//검색 목록의 데이터를 테이블 뷰의 DataSource에 추가
extension MedicineSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineListCell")!
        
        let itemName = itemNames[indexPath.row]
        let company = company[indexPath.row]
        
        cell.textLabel!.text = itemName
        cell.detailTextLabel!.text = company
        
        return cell
    }
}

//검색한 약의 자세한 정보를 보여주기 위한 데이터 전달
extension MedicineSearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let medicineInfoViewController = segue.destination as! MedicineInfoViewController
        
        if let row = medicineListTableView.indexPathForSelectedRow?.row {
            medicineInfoViewController.infos = extractMedicineData(jsonData: self.data!, row: row)
        }
    }
}
