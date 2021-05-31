//
//  AddTakeMedicineViewController.swift
//  MedInfo
//
//  Created by JJW on 2021/05/27.
//

import UIKit

class AddTakeMedicineViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var etcTextView: UITextView!
    
    var takeMedicineTableView: UITableView?
    var takeMedicineGroup: TakeMedicineGroup?
    var takeMedicine: TakeMedicine?
    var time = Date()
}

extension AddTakeMedicineViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        etcTextView.layer.borderWidth = 1.0
        etcTextView.layer.cornerRadius = 5
        etcTextView.layer.borderColor = UIColor.systemGray5.cgColor
        
        nameTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
    }
}

//화면 터치시 키보드 내리기
extension AddTakeMedicineViewController {
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

//DatePicker 값 변경시 저장
extension AddTakeMedicineViewController {
    @IBAction func timeDatePicker(_ sender: UIDatePicker) {
        time = sender.date
    }
}

//완료버튼 눌렀을 경우 데이터를 저장, 복용기록 씬의 테이블 뷰에 저장 후 리로드
extension AddTakeMedicineViewController {
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        if let takeMedicine = takeMedicine {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M/d(E) a h시 m분"
            dateFormatter.locale = Locale(identifier:"ko_KR")
            
            takeMedicine.name = nameTextField.text
            takeMedicine.time = dateFormatter.string(from: time)
            takeMedicine.etc = etcTextView.text
        }
        let indexPath = IndexPath(row: takeMedicineGroup!.takeMedicines.count - 1, section: 0)
        takeMedicineTableView?.reloadRows(at: [indexPath], with: .automatic)
        
        let defaults = UserDefaults.standard
        
        defaults.set(takeMedicineGroup!.count(), forKey: "count")
        print("Data Count: " + String(takeMedicineGroup!.count()))
        print("Data Saving")
        
        for i in 0 ..< takeMedicineGroup!.count() {
            defaults.set(takeMedicineGroup!.takeMedicines[i].name, forKey: "takeMedicineName" + String(i))
            defaults.set(takeMedicineGroup!.takeMedicines[i].time, forKey: "takeMedicineTime" + String(i))
            defaults.set(takeMedicineGroup!.takeMedicines[i].etc, forKey: "takeMedicineEtc" + String(i))
            print(takeMedicineGroup!.takeMedicines[i].name! + " is Saved")
        }
        
        print("All Data Saved!")
        
        dismiss(animated: true, completion: nil)
    }
}

//취소 버튼을 눌렀을 경우 새로 추가하기 위해 만들었던 데이터를 삭제, 복용기록 씬의 테이블 뷰에도 삭제
extension AddTakeMedicineViewController {
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        let indexPath = IndexPath(row: takeMedicineGroup!.takeMedicines.count - 1, section: 0)
        
        takeMedicineGroup!.removeTakeMedicine(index: indexPath.row)
        takeMedicineTableView!.deleteRows(at: [indexPath], with: .automatic)
        
        dismiss(animated: true, completion: nil)
    }
}

//약이름 입력시 키보드의 완료버튼을 누르면 키보드 내리기
extension AddTakeMedicineViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
}
