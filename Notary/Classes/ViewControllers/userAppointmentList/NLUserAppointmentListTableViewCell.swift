//
//  NLUserAppointmentListTableViewCell.swift
//  Notary
//
//  Created by Admin on 3/20/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class NLUserAppointmentListTableViewCell: UITableViewCell {

    @IBOutlet weak var bgMain: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var object: TAppointments? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    func configureCell() {
        if !(self.object != nil) {
            return
        }
        //    NSDate *dt = [NSDate dateFromString:self.object.s_datetime withFormat:@"yyyy-MM-dd"];//[NSDate dateFromString:self.object.dateTime withFormat:@"yyyyMMdd"];

        let dt = NSDate.init(from: self.object!.s_datetime, withFormat: "yyMMddHHmm")
        let str = NSDate.string(from: dt as Date!, withFormat: "MMMM EEEE, yyyy")
        self.lblDate.text = str
        let service = TServices.mr_findFirst(with: NSPredicate(format: "pk_i_id = %@", self.object!.fk_i_service_id!))
        self.lblAddress.text = service?.s_name
        if self.object!.b_cancelled {
            self.bgMain.backgroundColor = UIColor.groupTableViewBackground
        }
        else {
            self.bgMain.backgroundColor = UIColor(red: 248.0 / 255.0, green: 247.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
