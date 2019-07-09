package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.workbench.domain.ActivityRemark;

import java.util.List;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/6/29_20:53 
*/
public interface ActivityRemarkDao {

    List<ActivityRemark> activityRemark(String activityId);

    int saveRemark(ActivityRemark remark);

    int deleteRemark(String id);

    int editRemark(ActivityRemark remark);
}
