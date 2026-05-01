package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.OrderItemDto;
import java.util.List;
import java.util.UUID;

public interface IOrderItemService {
    List<OrderItemDto> getAll();

    OrderItemDto getById(UUID id);

    OrderItemDto create(OrderItemDto dto);

    OrderItemDto update(UUID id, OrderItemDto dto);

    void delete(UUID id);
}