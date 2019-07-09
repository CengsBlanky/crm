package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/6/29_20:52 
*/
public interface ActivityDao {
    List<User> FindUsers();

    int saveActivity(Activity activity);

    int totalRecord(Map map);

    List<Activity> searchActivity(Map map);

    int deleteActivity(String[] ids);

    Activity findActivityById(String activityId);

    int updateActivity(Activity activity);

    int activityRemarkCount(String[] ids);

    int deleteActivityRemarkByActivityId(String[] ids);

    Activity detailDisplay(String activityId);

    List<Activity> findActivityByName(String activityName);
}
