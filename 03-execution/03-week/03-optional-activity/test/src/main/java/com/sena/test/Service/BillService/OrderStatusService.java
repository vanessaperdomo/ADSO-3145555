package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.OrderStatusDto;
import com.sena.test.Entity.Bill.OrderStatus;
import com.sena.test.IRepository.IBillRepository.IOrderStatusRepository;
import com.sena.test.IService.IBillService.IOrderStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class OrderStatusService implements IOrderStatusService {

    @Autowired
    private IOrderStatusRepository repository;

    private OrderStatusDto toDto(OrderStatus e) {
        OrderStatusDto dto = new OrderStatusDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    private OrderStatus toEntity(OrderStatusDto dto) {
        OrderStatus e = new OrderStatus();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<OrderStatusDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public OrderStatusDto getById(UUID id) {
        OrderStatus e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public OrderStatusDto create(OrderStatusDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public OrderStatusDto update(UUID id, OrderStatusDto dto) {
        OrderStatus e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}