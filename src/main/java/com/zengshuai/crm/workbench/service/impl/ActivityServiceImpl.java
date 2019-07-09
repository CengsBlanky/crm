package com.zengshuai.crm.workbench.service.impl;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.SqlSessionUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.dao.ActivityDao;
import com.zengshuai.crm.workbench.dao.ActivityRemarkDao;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.ActivityRemark;
import com.zengshuai.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/6/29_20:58 
*/
public class ActivityServiceImpl implements ActivityService {
    private ActivityDao ad = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao ar = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);

    @Override
    public List<User> FindUsers() {
        return ad.FindUsers();
    }

    @Override
    public int SaveActivity(Activity activity) {
        return ad.saveActivity(activity);
    }

    @Override
    public Pagination showActivityList(Map map) {
        //调用dao层返回list
        List<Activity> list = ad.searchActivity(map);
        //调用dao层返回totalRecord
        int totalRecord = ad.totalRecord(map);
        //封装成vo返回
        Pagination<Activity> pagination = new Pagination<>();
        pagination.setDataList(list);
        pagination.setTotalRecord(totalRecord);
        return pagination;
    }

    @Override
    public boolean deleteActivity(String[] ids) {
        //应当删除的活动数：
        int num1 = ids.length;
        //实际删除的活动数
        int num2 = ad.deleteActivity(ids);
        //应当删除的关联表(活动备注表)记录数
        int num3 = ad.activityRemarkCount(ids);
        //实际删除的关联表(活动备注表)记录数
        int num4 = ad.deleteActivityRemarkByActivityId(ids);
        if(num1==num2 && num3==num4){
            return true;
        }
        return false;
    }

    @Override
    public Map<String, Object> findUsersAndActivities(String activityId) {
        List<User> uList = ad.FindUsers();
        Activity activity = ad.findActivityById(activityId);
        Map<String, Object> map = new HashMap<>();
        map.put("uList",uList);
        map.put("activity",activity);
        return map;
    }

    @Override
    public boolean updateActivity(Activity activity) {
        int flag = ad.updateActivity(activity);
        return flag==1;
    }

    @Override
    public Activity detailDisplay(String activityId) {
        //使用DAO返回activity字段的owner是联表查询对应的所有者姓名
        return ad.detailDisplay(activityId);
    }

    @Override
    public List<ActivityRemark> activityRemark(String activityId) {
        return ar.activityRemark(activityId);
    }

    @Override
    public boolean saveRemark(ActivityRemark remark) {
        int flag = ar.saveRemark(remark);
        return flag==1;
    }

    @Override
    public boolean deleteRemark(String id) {
        int flag = ar.deleteRemark(id);
        return flag==1;
    }

    @Override
    public boolean editRemark(ActivityRemark remark) {
        int flag = ar.editRemark(remark);
        return flag==1;
    }
}
