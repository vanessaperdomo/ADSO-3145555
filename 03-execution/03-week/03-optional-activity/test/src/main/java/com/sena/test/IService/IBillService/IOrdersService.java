package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.OrdersDto;
import java.util.List;
import java.util.UUID;

public interface IOrdersService {
    List<OrdersDto> getAll();

    OrdersDto getById(UUID id);

    OrdersDto create(OrdersDto dto);

    OrdersDto update(UUID id, OrdersDto dto);

    void delete(UUID id);
}