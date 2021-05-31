//
//  TakeMedicineListViewController.swift
//  MedInfo
//
//  Created by JJW on 2021/05/26.
//

import UIKit
import LocalAuthentication

class TakeMedicineListViewController: UIViewController {
    @IBOutlet weak var takeMedicineListTableView: UITableView!
    
    var takeMedicineGroup: TakeMedicineGroup!
    let defaults = UserDefaults.standard
    
    let authContext = LAContext()
    var error: NSError?
    
    var doFirstSuccess = false // 데이터를 한 번만 로딩하기 위한 변수
}

extension TakeMedicineListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeMedicineGroup = TakeMedicineGroup()
        
        takeMedicineListTableView.dataSource = self
        takeMedicineListTableView.delegate = self
        
        //길게 누르고 있을 경우 테이블 수정
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editTableView))
        takeMedicineListTableView.addGestureRecognizer(longPressGesture)
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "암호를 입력해주세요.") { (success, error) in
                if success {
                    //복용기록 데이터 불러오기
                    if self.doFirstSuccess == false { //한번도 success가 된 적 없을 경우만 로딩(한번만 로딩)
                        let count = self.defaults.integer(forKey: "count")
                        
                        print("Data Count: " + String(count))
                        print("Data loading")
                        for i in 0 ..< count {
                            let name = self.defaults.string(forKey: "takeMedicineName" + String(i))
                            let time = self.defaults.string(forKey: "takeMedicineTime" + String(i))
                            let etc = self.defaults.string(forKey: "takeMedicineEtc" + String(i))
                            
                            self.takeMedicineGroup.addTakeMedicine(takeMedicine: TakeMedicine(name: name, time: time, etc: etc))
                            
                            print(name! + " is loaded")
                        }
                        print("All Data Loaded")
                        
                        DispatchQueue.main.async {
                            self.takeMedicineListTableView.reloadData()
                        }
                    }
                    
                    self.doFirstSuccess = true
                } else {
                    //실패 시 의약품 검색 탭으로 강제 이동
                    DispatchQueue.main.async {
                        let tabBarController = self.parent?.parent as! UITabBarController
                        let searchViewController = tabBarController.viewControllers![0] as! UINavigationController
                        tabBarController.selectedViewController = searchViewController
                    }
                }
            }
        }
        
    }
}

extension TakeMedicineListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return takeMedicineGroup.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "takeMedicineListTableViewCell")!
        let takeMedicine = takeMedicineGroup.takeMedicines[indexPath.row]
        
        cell.textLabel?.text = takeMedicine.name
        cell.detailTextLabel?.text = takeMedicine.time
        
        return cell
    }
}

//복용기록 데이터 삭제, 삭제 후 남아있는 데이터들 저장
extension TakeMedicineListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.takeMedicineGroup.removeTakeMedicine(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
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
            
        }
    }
    
    //테이블 뷰에서 왼쪽으로 드래그할 경우 삭제 버튼, 길게 당기면 삭제
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
}

//셀 길게 누를 경우 손 끝을 따라 다닐 셀을 이미지화
extension TakeMedicineListViewController {
    func takeCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cell: UIView = UIImageView(image: image)
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 0
        cell.layer.shadowOffset = CGSize(width: -5, height: 0)
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.4
        
        return cell
    }
}

//길게 눌렀을 경우 실제 데이터들을 변경
extension TakeMedicineListViewController {
    @objc func editTableView(_ longPress: UILongPressGestureRecognizer) {
        struct Cell {
            static var cell: UIView?
        }
        struct Path {
            static var firstIndexPath: IndexPath?
        }
        
        let location = longPress.location(in: takeMedicineListTableView)
        let indexPath = takeMedicineListTableView.indexPathForRow(at: location)
        
        switch longPress.state {
        case UIGestureRecognizer.State.began:
            //처음 인덱스 저장, 이미지화
            guard let indexPath = indexPath else {return}
            guard  let cell = takeMedicineListTableView.cellForRow(at: indexPath) else {return}
            Path.firstIndexPath = indexPath
            Cell.cell = takeCell(cell)
            
            //이미지화한 것의 센터값 설정
            var center = cell.center
            Cell.cell!.center = center
            Cell.cell!.alpha = 0
            takeMedicineListTableView.addSubview(Cell.cell!)
            
            //이미지화 애니메이션
            UIView.animate(withDuration: 0.25, animations: { () -> Void in center.y = location.y
                Cell.cell!.center = center
                Cell.cell!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                Cell.cell!.alpha = 0.98
                cell.alpha = 0
            }, completion: { (finished) -> Void in if finished {
                cell.isHidden = true
            }})
        case UIGestureRecognizer.State.changed:
            //선택한 셀을 위아래로 드래그 할 경우 손 끝을 따라갈 수 있게 위치 수정
            var center = Cell.cell!.center
            center.y = location.y
            Cell.cell!.center = center
            
            //처음 인덱스와 다른 인덱스를 만나면 데이터 값들 변경
            if((indexPath) != nil) && (indexPath != Path.firstIndexPath) {
                
                let from = takeMedicineGroup.takeMedicines[indexPath!.row]
                let to = takeMedicineGroup.takeMedicines[Path.firstIndexPath!.row]
                
                takeMedicineGroup.modifyTakeMedicine(takeMedicine: from, index: Path.firstIndexPath!.row)
                takeMedicineGroup.modifyTakeMedicine(takeMedicine: to, index: indexPath!.row)
                
                takeMedicineListTableView.moveRow(at: Path.firstIndexPath!, to: indexPath!)
                
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
                
                Path.firstIndexPath = indexPath
            }
        default:
            //손을 놓으면 셀이 정상적으로 들어가는 애니메이션
            guard let cell = takeMedicineListTableView.cellForRow(at: Path.firstIndexPath!) else { return }
            cell.isHidden = false
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                Cell.cell!.center = cell.center
                Cell.cell!.transform = CGAffineTransform.identity
                Cell.cell!.alpha = 0
                cell.alpha = 1
            }, completion: { (finished) -> Void in
                if finished {
                    Path.firstIndexPath = nil
                    Cell.cell!.removeFromSuperview()
                    Cell.cell = nil
                }
            })
        }
    }
}

extension TakeMedicineListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailTakeMedicineViewController = segue.destination as! DetailTakeMedicineViewController
            
            if let row = takeMedicineListTableView.indexPathForSelectedRow?.row {
                detailTakeMedicineViewController.takeMedicine = takeMedicineGroup.takeMedicines[row]
            }
        } else if segue.identifier == "ShowAddTakeMedicineViewController" {
            let takeMedicine = TakeMedicine()
            takeMedicineGroup.addTakeMedicine(takeMedicine: takeMedicine)
            
            let indexPath = IndexPath(row: takeMedicineGroup.takeMedicines.count - 1, section: 0)
            takeMedicineListTableView.insertRows(at: [indexPath], with: .automatic)
            
            let addTakeMedicineViewController = segue.destination as! AddTakeMedicineViewController
            addTakeMedicineViewController.takeMedicine = takeMedicineGroup.takeMedicines[indexPath.row]
            addTakeMedicineViewController.takeMedicineGroup = takeMedicineGroup
            addTakeMedicineViewController.takeMedicineTableView = takeMedicineListTableView
        }
    }
}
