package com.ems.east.module.system.service.permission;

import com.ems.east.framework.common.enums.CommonStatusEnum;
import com.ems.east.framework.test.core.ut.BaseDbUnitTest;
import com.ems.east.module.system.controller.admin.permission.vo.menu.MenuListReqVO;
import com.ems.east.module.system.controller.admin.permission.vo.menu.MenuSaveVO;
import com.ems.east.module.system.dal.dataobject.permission.MenuDO;
import com.ems.east.module.system.dal.mysql.permission.MenuMapper;
import com.ems.east.module.system.enums.permission.MenuTypeEnum;
import jakarta.annotation.Resource;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;

import static com.ems.east.framework.common.util.object.ObjectUtils.cloneIgnoreId;
import static com.ems.east.framework.test.core.util.AssertUtils.assertPojoEquals;
import static com.ems.east.framework.test.core.util.AssertUtils.assertServiceException;
import static com.ems.east.framework.test.core.util.RandomUtils.randomCommonStatus;
import static com.ems.east.framework.test.core.util.RandomUtils.randomLongId;
import static com.ems.east.framework.test.core.util.RandomUtils.randomPojo;
import static com.ems.east.module.system.dal.dataobject.permission.MenuDO.ID_ROOT;
import static com.ems.east.module.system.enums.ErrorCodeConstants.MENU_EXISTS_CHILDREN;
import static com.ems.east.module.system.enums.ErrorCodeConstants.MENU_NOT_EXISTS;
import static com.ems.east.module.system.enums.ErrorCodeConstants.MENU_PARENT_NOT_EXISTS;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.verify;

@Import(MenuServiceImpl.class)
class MenuServiceImplTest extends BaseDbUnitTest {

    @Resource
    private MenuServiceImpl menuService;
    @Resource
    private MenuMapper menuMapper;

    @MockitoBean
    private PermissionService permissionService;

    @Test
    void testCreateMenu_success() {
        MenuDO parent = buildMenuDO(MenuTypeEnum.MENU, "parent", ID_ROOT);
        menuMapper.insert(parent);
        MenuSaveVO reqVO = randomPojo(MenuSaveVO.class, o -> {
            o.setParentId(parent.getId());
            o.setName("child");
            o.setType(MenuTypeEnum.MENU.getType());
        }).setId(null);

        Long menuId = menuService.createMenu(reqVO);
        MenuDO dbMenu = menuMapper.selectById(menuId);
        assertPojoEquals(reqVO, dbMenu, "id");
    }

    @Test
    void testDeleteMenu_success() {
        MenuDO menuDO = randomPojo(MenuDO.class);
        menuMapper.insert(menuDO);

        menuService.deleteMenu(menuDO.getId());
        assertNull(menuMapper.selectById(menuDO.getId()));
        verify(permissionService).processMenuDeleted(menuDO.getId());
    }

    @Test
    void testDeleteMenu_existChildren() {
        MenuDO sonMenu = createParentAndSonMenu();
        assertServiceException(() -> menuService.deleteMenu(sonMenu.getParentId()), MENU_EXISTS_CHILDREN);
    }

    @Test
    void testGetMenuList_filtersByStatus() {
        MenuDO enabled = randomPojo(MenuDO.class, o -> o.setStatus(CommonStatusEnum.ENABLE.getStatus()).setName("A"));
        menuMapper.insert(enabled);
        menuMapper.insert(cloneIgnoreId(enabled, o -> o.setStatus(CommonStatusEnum.DISABLE.getStatus())));

        MenuListReqVO reqVO = new MenuListReqVO().setStatus(CommonStatusEnum.ENABLE.getStatus());
        List<MenuDO> result = menuService.getMenuList(reqVO);
        assertEquals(1, result.size());
        assertPojoEquals(enabled, result.get(0));
    }

    @Test
    void testValidateParentMenu_parentNotExist() {
        assertServiceException(() -> menuService.validateParentMenu(randomLongId(), null), MENU_PARENT_NOT_EXISTS);
    }

    @Test
    void testUpdateMenu_menuNotExist() {
        assertServiceException(() -> menuService.updateMenu(randomPojo(MenuSaveVO.class)), MENU_NOT_EXISTS);
    }

    private MenuDO createParentAndSonMenu() {
        MenuDO parentMenu = buildMenuDO(MenuTypeEnum.MENU, "parent", ID_ROOT);
        menuMapper.insert(parentMenu);
        MenuDO sonMenu = buildMenuDO(MenuTypeEnum.MENU, "child", parentMenu.getId());
        menuMapper.insert(sonMenu);
        return sonMenu;
    }

    private MenuDO buildMenuDO(MenuTypeEnum type, String name, Long parentId) {
        return randomPojo(MenuDO.class, o -> o.setId(null).setName(name).setParentId(parentId)
                .setType(type.getType()).setStatus(randomCommonStatus()));
    }

}
