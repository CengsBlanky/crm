package com.zengshuai.crm.workbench.service;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService<T> {
    List<User> FindUsers();
    int SaveActivity(Activity activity);

    Pagination showActivityList(Map<String, String> map);

    boolean deleteActivity(String[] ids);


    Map<String, Object> findUsersAndActivities(String activityId);

    boolean updateActivity(Activity activity);

    Activity detailDisplay(String activityId);

    List<ActivityRemark> activityRemark(String activityId);

    boolean saveRemark(ActivityRemark remark);

    boolean deleteRemark(String id);

    boolean editRemark(ActivityRemark remark);
}
