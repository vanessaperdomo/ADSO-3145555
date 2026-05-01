package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.OrdersDto;
import com.sena.test.Entity.Bill.OrderStatus;
import com.sena.test.Entity.Bill.Orders;
import com.sena.test.Entity.Security.Customer;
import com.sena.test.IRepository.IBillRepository.IOrderStatusRepository;
import com.sena.test.IRepository.IBillRepository.IOrdersRepository;
import com.sena.test.IRepository.ISecurityRepository.ICustomerRepository;
import com.sena.test.IService.IBillService.IOrdersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class OrdersService implements IOrdersService {

    @Autowired
    private IOrdersRepository repository;

    @Autowired
    private IOrderStatusRepository orderStatusRepository;

    @Autowired
    private ICustomerRepository customerRepository;

    private OrdersDto toDto(Orders e) {
        OrdersDto dto = new OrdersDto();
        dto.setId(e.getId());
        dto.setTotalAmount(e.getTotalAmount());
        dto.setStatusId(e.getStatus().getId());
        dto.setCustomerId(e.getCustomer().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    private Orders toEntity(OrdersDto dto) {
        Orders e = new Orders();
        e.setTotalAmount(dto.getTotalAmount());
        OrderStatus status = orderStatusRepository.findById(dto.getStatusId()).orElse(null);
        e.setStatus(status);
        Customer customer = customerRepository.findById(dto.getCustomerId()).orElse(null);
        e.setCustomer(customer);
        return e;
    }

    @Override
    public List<OrdersDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public OrdersDto getById(UUID id) {
        Orders e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public OrdersDto create(OrdersDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public OrdersDto update(UUID id, OrdersDto dto) {
        Orders e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setTotalAmount(dto.getTotalAmount());
        OrderStatus status = orderStatusRepository.findById(dto.getStatusId()).orElse(null);
        e.setStatus(status);
        Customer customer = customerRepository.findById(dto.getCustomerId()).orElse(null);
        e.setCustomer(customer);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}