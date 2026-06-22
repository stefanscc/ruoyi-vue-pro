package com.ems.yudao.module.wms.service.md.warehouse;

import com.ems.yudao.framework.test.core.ut.BaseDbUnitTest;
import com.ems.yudao.module.wms.controller.admin.md.warehouse.vo.WmsWarehouseSaveReqVO;
import com.ems.yudao.module.wms.dal.dataobject.md.warehouse.WmsWarehouseDO;
import com.ems.yudao.module.wms.dal.mysql.md.warehouse.WmsWarehouseMapper;
import com.ems.yudao.module.wms.service.inventory.WmsInventoryService;
import com.ems.yudao.module.wms.service.order.check.WmsCheckOrderService;
import com.ems.yudao.module.wms.service.order.movement.WmsMovementOrderService;
import com.ems.yudao.module.wms.service.order.receipt.WmsReceiptOrderService;
import com.ems.yudao.module.wms.service.order.shipment.WmsShipmentOrderService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;

import javax.annotation.Resource;

import static com.ems.yudao.framework.test.core.util.AssertUtils.assertServiceException;
import static com.ems.yudao.module.wms.enums.ErrorCodeConstants.WAREHOUSE_CODE_DUPLICATE;
import static com.ems.yudao.module.wms.enums.ErrorCodeConstants.WAREHOUSE_HAS_INVENTORY;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.when;

@Import(WmsWarehouseServiceImpl.class)
public class WmsWarehouseServiceImplTest extends BaseDbUnitTest {

    @Resource
    private WmsWarehouseServiceImpl warehouseService;

    @Resource
    private WmsWarehouseMapper warehouseMapper;

    @MockBean
    private WmsInventoryService inventoryService;
    @MockBean
    private WmsReceiptOrderService receiptOrderService;
    @MockBean
    private WmsShipmentOrderService shipmentOrderService;
    @MockBean
    private WmsMovementOrderService movementOrderService;
    @MockBean
    private WmsCheckOrderService checkOrderService;

    @Test
    public void testCreateWarehouse_codeDuplicate() {
        // mock 数据
        WmsWarehouseDO warehouse = createWarehouse("WH001", "成品仓");
        warehouseMapper.insert(warehouse);

        // 调用，并断言
        WmsWarehouseSaveReqVO reqVO = createWarehouseSaveReqVO();
        assertServiceException(() -> warehouseService.createWarehouse(reqVO), WAREHOUSE_CODE_DUPLICATE);
    }

    @Test
    public void testUpdateWarehouse_codeDuplicate() {
        // mock 数据
        WmsWarehouseDO warehouse = createWarehouse("WH001", "成品仓");
        warehouseMapper.insert(warehouse);
        WmsWarehouseDO updateWarehouse = createWarehouse("WH002", "原料仓");
        warehouseMapper.insert(updateWarehouse);

        // 调用，并断言
        WmsWarehouseSaveReqVO reqVO = createWarehouseSaveReqVO();
        reqVO.setId(updateWarehouse.getId());
        assertServiceException(() -> warehouseService.updateWarehouse(reqVO), WAREHOUSE_CODE_DUPLICATE);
    }

    @Test
    public void testDeleteWarehouse_hasInventory() {
        // mock 数据
        WmsWarehouseDO warehouse = createWarehouse();
        warehouseMapper.insert(warehouse);
        when(inventoryService.getInventoryCountByWarehouseId(warehouse.getId())).thenReturn(1L);

        // 调用，并断言
        assertServiceException(() -> warehouseService.deleteWarehouse(warehouse.getId()), WAREHOUSE_HAS_INVENTORY);
        assertNotNull(warehouseMapper.selectById(warehouse.getId()));
    }

    private static WmsWarehouseDO createWarehouse() {
        return createWarehouse("WH001", "成品仓");
    }

    private static WmsWarehouseDO createWarehouse(String code, String name) {
        return WmsWarehouseDO.builder()
                .code(code)
                .name(name)
                .sort(1)
                .build();
    }

    private static WmsWarehouseSaveReqVO createWarehouseSaveReqVO() {
        WmsWarehouseSaveReqVO reqVO = new WmsWarehouseSaveReqVO();
        reqVO.setCode("WH001");
        reqVO.setName("半成品仓");
        reqVO.setSort(1);
        return reqVO;
    }

}
