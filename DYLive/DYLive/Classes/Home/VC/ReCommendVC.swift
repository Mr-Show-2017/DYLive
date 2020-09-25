//
//  ReCommendVC.swift
//  DYLive
//
//  Created by MR.Sahw on 2020/9/24.
//

import UIKit

private let kItenmMargin :CGFloat = 10
private let kItemW = (kScreenW - 3*kItenmMargin) / 2
private let kNormalItemH = kItemW * 3 / 4
private let kPrettyItemH = kItemW * 4 / 3
private let kHeaderViewH : CGFloat = 50

private let kCycleViewH = kScreenW * 3 / 8
private let krecomendGameH : CGFloat = 90

private let kNormalCellID : String = "kNormalCellID"
private let kPrettyCellID : String = "kPrettyCellID"
private let kHeaderViewID : String = "kHeaderViewID"

class ReCommendVC: UIViewController {
    // MARK - 懒加载属性
    private lazy var recommendVM : RecommendViewModel = RecommendViewModel()
    private lazy var collectionView : UICollectionView = {[unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kItemW, height: kNormalItemH)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = kItenmMargin
        layout.headerReferenceSize = CGSize(width: kScreenW, height: kHeaderViewH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: kItenmMargin, bottom: 0, right: kItenmMargin)
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        collectionView.register(UINib(nibName: "CollectionViewNormalCell", bundle: nil), forCellWithReuseIdentifier: kNormalCellID)
        collectionView.register(UINib(nibName: "CollectionPrettyCell", bundle: nil), forCellWithReuseIdentifier: kPrettyCellID)
        collectionView.register(UINib(nibName: "CollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kHeaderViewID)
        return collectionView
    }()
    // MARK - 懒加载属性
    private lazy var cycleView : CommendCyleView = {
        let cycleView = CommendCyleView.recommedCycleView()
        cycleView.frame = CGRect(x: 0, y: -(kCycleViewH+krecomendGameH), width: kScreenW, height: kCycleViewH)
        return cycleView
    }()
    // MARK - 懒加载属性
    private lazy var recommendGameV : RecommendGameView = {
        let recommendGameview = RecommendGameView.recommendGameView()
        recommendGameview.frame = CGRect(x: 0, y: -krecomendGameH, width: kScreenW, height: krecomendGameH)
        return recommendGameview
    }()
    // MARK -系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.red
        setupUI()
        // 发送数据请求
        loadData()
    }
    
}

extension ReCommendVC {
    private func setupUI() {
        // 将 collectionView 添加到view
        view.addSubview(collectionView)
        // 将 cycleView 添加到collectionView
        collectionView.addSubview(cycleView)
        // 将 recommedGameView 添加到collectionView
        collectionView.addSubview(recommendGameV)
        // 设置collectionView 顶部内边距 (轮播图出现)
        collectionView.contentInset = UIEdgeInsets(top: kCycleViewH + krecomendGameH, left: 0, bottom: 0, right: 0)
    }
}
// MARK 请求数据
extension ReCommendVC {
    private func loadData() {
        // 请求推荐数据
        recommendVM.requesData {
            self.collectionView.reloadData()
            self.recommendGameV.groups = self.recommendVM.anchorGroups
        }
        // 请求轮播数据
        recommendVM.requestCycleDate {
            self.cycleView.cycleModels = self.recommendVM.cycleModels
        }
    }
}
// MARK 遵守 UICollectionViewDataSource
extension ReCommendVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return recommendVM.anchorGroups.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = recommendVM.anchorGroups[section]
        return group.anchors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.取出模型对象
        let group = recommendVM.anchorGroups[indexPath.section]
        let anchor = group.anchors[indexPath.item]
        
        // 2.定义cell
        var cell : CollectionBaseCell!
        
        if indexPath.section == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPrettyCellID, for: indexPath) as! CollectionPrettyCell
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: kNormalCellID, for: indexPath) as! CollectionViewNormalCell
        }
        cell.anchor = anchor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 1.取出section的headerview
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kHeaderViewID, for: indexPath) as! CollectionHeaderView
        // 2.取出模型
        headerView.group = recommendVM.anchorGroups[indexPath.section]
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: kItemW, height: kPrettyItemH)
        }
        return CGSize(width: kItemW, height: kNormalItemH)
    }
}
