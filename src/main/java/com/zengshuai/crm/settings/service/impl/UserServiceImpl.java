package com.zengshuai.crm.settings.service.impl;

import com.zengshuai.crm.exception.LoginException;
import com.zengshuai.crm.settings.dao.UserDao;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.settings.service.UserService;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.MD5Util;
import com.zengshuai.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.Map;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/6/29_12:58 
*/
public class UserServiceImpl implements UserService {
    private UserDao ud = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginException{
        Map<String,String> map = new HashMap<>();
        loginPwd = MD5Util.getMD5(loginPwd);
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        User user = ud.login(map);

        //如果返回结果为空，说明账号密码有误
        if(user == null){
            throw new LoginException("账号或密码错误");
        }

        //验证账号是否在有效期
        String curTime = DateTimeUtil.getSysTime();
        String expireTime = user.getExpireTime();
        if(expireTime.compareTo(curTime) < 0){
            throw new LoginException("账号已过期");
        }

        //验证账号是否被锁定
        String lockState = user.getLockState();
        if("0".equals(lockState)){
            throw new LoginException("该账号已被锁定");
        }

        //验证IP地址，是否允许访问
        String allowIps = user.getAllowIps();
        if(!allowIps.contains(ip)){
            throw new LoginException("IP地址禁止访问");
        }

        return user;
    }
}
