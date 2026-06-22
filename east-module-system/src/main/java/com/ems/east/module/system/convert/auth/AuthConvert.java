package com.ems.east.module.system.convert.auth;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjUtil;
import com.ems.east.framework.common.util.object.BeanUtils;
import com.ems.east.module.system.controller.admin.auth.vo.AuthPermissionInfoRespVO;
import com.ems.east.module.system.dal.dataobject.permission.MenuDO;
import com.ems.east.module.system.dal.dataobject.permission.RoleDO;
import com.ems.east.module.system.dal.dataobject.user.AdminUserDO;
import com.ems.east.module.system.enums.permission.MenuTypeEnum;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static com.ems.east.framework.common.util.collection.CollectionUtils.convertSet;
import static com.ems.east.framework.common.util.collection.CollectionUtils.filterList;
import static com.ems.east.module.system.dal.dataobject.permission.MenuDO.ID_ROOT;

@Mapper
public interface AuthConvert {

    AuthConvert INSTANCE = Mappers.getMapper(AuthConvert.class);

    default AuthPermissionInfoRespVO convert(AdminUserDO user, List<RoleDO> roleList, List<MenuDO> menuList) {
        return AuthPermissionInfoRespVO.builder()
                .user(BeanUtils.toBean(user, AuthPermissionInfoRespVO.UserVO.class))
                .roles(convertSet(roleList, RoleDO::getCode))
                .permissions(convertSet(menuList, MenuDO::getPermission))
                .menus(buildMenuTree(menuList))
                .build();
    }

    default List<AuthPermissionInfoRespVO.MenuVO> buildMenuTree(List<MenuDO> menuList) {
        if (CollUtil.isEmpty(menuList)) {
            return Collections.emptyList();
        }
        menuList.removeIf(menu -> menu.getType().equals(MenuTypeEnum.BUTTON.getType()));
        menuList.sort(Comparator.comparing(MenuDO::getSort));

        Map<Long, AuthPermissionInfoRespVO.MenuVO> treeNodeMap = new LinkedHashMap<>();
        menuList.forEach(menu -> treeNodeMap.put(menu.getId(),
                BeanUtils.toBean(menu, AuthPermissionInfoRespVO.MenuVO.class)));
        treeNodeMap.values().stream().filter(node -> ObjUtil.notEqual(node.getParentId(), ID_ROOT)).forEach(childNode -> {
            AuthPermissionInfoRespVO.MenuVO parentNode = treeNodeMap.get(childNode.getParentId());
            if (parentNode == null) {
                LoggerFactory.getLogger(getClass()).error("[buildRouterTree][resource({}) missing parent({})]",
                        childNode.getId(), childNode.getParentId());
                return;
            }
            if (parentNode.getChildren() == null) {
                parentNode.setChildren(new ArrayList<>());
            }
            parentNode.getChildren().add(childNode);
        });
        return filterList(treeNodeMap.values(), node -> ID_ROOT.equals(node.getParentId()));
    }

}
