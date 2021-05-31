//
//  MedicineInfoViewController.swift
//  MedInfo
//
//  Created by JJW on 2021/05/24.
//

import UIKit

class MedicineInfoViewController: UIViewController {
    @IBOutlet weak var medicineInfoTableView: UITableView!
    
    var infos: [String?] = []
    let tableTitles: [String] = ["제품명", "업체명", "효능", "사용법", "사용 전 주의사항", "사용상 주의사항", "주의할 약 또는 음식", "부작용", "보관법"]
}

extension MedicineInfoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< infos.count {
            if infos[i] == nil { // 자세한 정보 중 내용이 없는 항목은 정보 없음을 출력
                infos[i] = "정보 없음"
            }
            // json을 파싱 한 데이터들 중 태그가 있는 경우 태그들만 제거
            infos[i] = infos[i]?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
        
        medicineInfoTableView.dataSource = self
        medicineInfoTableView.delegate = self
    }
}

//데이터들을 테이블 뷰의 DataSource로 추가
extension MedicineInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineInfoTableViewCell") as! MedicineInfoTableViewCell
        
        cell.titleTextLabel?.text = tableTitles[indexPath.row]
        cell.customDetailTextLabel?.text = infos[indexPath.row]
        
        return cell
    }
}

// 테이블 뷰의 Cell 높이를 데이터의 양이 잘 출력될 수 있게 동적으로 변경
extension MedicineInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
