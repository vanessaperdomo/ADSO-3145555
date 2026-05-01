package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.OrderStatusDto;
import java.util.List;
import java.util.UUID;

public interface IOrderStatusService {
    List<OrderStatusDto> getAll();

    OrderStatusDto getById(UUID id);

    OrderStatusDto create(OrderStatusDto dto);

    OrderStatusDto update(UUID id, OrderStatusDto dto);

    void delete(UUID id);
}