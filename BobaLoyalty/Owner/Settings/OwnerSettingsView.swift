//
//  OwnerSettingsView.swift
//  BobaLoyalty
//
//  老板端 Tab 4：设置
//  - 门店：店名 / 营业时间
//  - 会员运营：群发促销券（SWAddSheet 输入面额）/ 重置 mock 数据（二次确认）
//  - 账号：登录方式（mock）
//  - 其他：版本号 / 切换角色 / 关于
//

import SwiftUI
import SwiftData

struct OwnerSettingsView: View {
    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue
    @AppStorage("storeName") private var storeName: String = "微茶 · 望京店"
    @AppStorage("openHours") private var openHours: String = "10:00 - 22:00"

    @Environment(\.modelContext) private var modelContext

    @Query private var customers: [Customer]
    @Query private var products: [Product]
    @Query private var orders: [Order]
    @Query private var coupons: [Coupon]

    @State private var showingPromoSheet = false
    @State private var showingResetConfirm = false
    @State private var showingRoleSwitchConfirm = false

    var body: some View {
        Form {
            // MARK: 门店
            Section("门店") {
                LabeledContent("门店名称") {
                    TextField("门店名称", text: $storeName)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("营业时间") {
                    TextField("营业时间", text: $openHours)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(Color("BobaPink"))
                    Text("当前会员数")
                    Spacer()
                    Text("\(customers.count)")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: 会员运营
            Section("会员运营") {
                Button {
                    showingPromoSheet = true
                } label: {
                    Label {
                        Text("群发促销券")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "ticket.fill")
                            .foregroundStyle(Color("BobaCaramel"))
                    }
                }

                Button(role: .destructive) {
                    showingResetConfirm = true
                } label: {
                    Label("重置 Mock 数据", systemImage: "arrow.counterclockwise")
                }
            }

            // MARK: 账号
            Section("账号") {
                LabeledContent("登录方式") {
                    HStack(spacing: 6) {
                        Image(systemName: "applelogo")
                        Text("Apple ID")
                    }
                    .foregroundStyle(.secondary)
                }
                LabeledContent("账号") {
                    Text("****@signerlabs.com")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: 其他
            Section("其他") {
                LabeledContent("版本号") {
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                NavigationLink {
                    aboutPage
                } label: {
                    Label("关于 BobaLoyalty", systemImage: "info.circle")
                }
                Button(role: .destructive) {
                    showingRoleSwitchConfirm = true
                } label: {
                    Label("切换角色", systemImage: "arrow.triangle.2.circlepath")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("设置")
        // 群发券 sheet
        .sheet(isPresented: $showingPromoSheet) {
            SWAddSheet(
                isPresented: $showingPromoSheet,
                title: "群发促销券",
                placeHolderText: "输入券面额（元），例如 5",
                minLines: 1
            ) { input in
                broadcastPromo(amountText: input)
            }
        }
        // 重置数据二次确认
        .alert("重置 Mock 数据", isPresented: $showingResetConfirm) {
            Button("取消", role: .cancel) {}
            Button("确认重置", role: .destructive) {
                resetMockData()
            }
        } message: {
            Text("将清空所有商品、订单、会员、优惠券，并重新灌入种子数据。")
        }
        // 切换角色二次确认
        .alert("切换角色", isPresented: $showingRoleSwitchConfirm) {
            Button("取消", role: .cancel) {}
            Button("退出老板端", role: .destructive) {
                withAnimation(.spring(duration: 0.4)) {
                    userRoleRaw = UserRole.unset.rawValue
                }
                SWAlertManager.shared.show(.info, message: "已退出老板端")
            }
        } message: {
            Text("退出后将回到角色选择页。")
        }
    }

    // MARK: - 群发促销券

    private func broadcastPromo(amountText: String) {
        let trimmed = amountText.trimmingCharacters(in: .whitespaces)
        guard let amount = Double(trimmed), amount > 0 else {
            SWAlertManager.shared.show(.error, message: "面额无效")
            return
        }
        guard !customers.isEmpty else {
            SWAlertManager.shared.show(.warning, message: "暂无会员")
            return
        }

        let expires = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
        for c in customers {
            let coupon = Coupon(
                kind: .promo,
                title: "全场满 \(Int(amount * 4)) 减 \(Int(amount)) 元",
                discountValue: amount,
                expiresAt: expires,
                customerID: c.id.uuidString
            )
            modelContext.insert(coupon)
        }
        SWAlertManager.shared.show(.success, message: "已发券给 \(customers.count) 位会员")
    }

    // MARK: - 重置 Mock 数据

    private func resetMockData() {
        do {
            // 删除所有 SwiftData 实体
            for o in orders { modelContext.delete(o) }
            for p in products { modelContext.delete(p) }
            for c in customers { modelContext.delete(c) }
            for cp in coupons { modelContext.delete(cp) }

            try modelContext.save()

            // 重新灌种子数据
            MockSeed.seedIfNeeded(in: modelContext)

            SWAlertManager.shared.show(.success, message: "Mock 数据已重置")
        } catch {
            SWAlertManager.shared.show(.error, message: "重置失败：\(error.localizedDescription)")
        }
    }

    // MARK: - 关于页

    private var aboutPage: some View {
        VStack(spacing: 18) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("BobaCaramel"))
            Text("BobaLoyalty")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color("BobaBrown"))
            Text("Vibe Coding 一个奶茶店点单 App\n· ShipSwift 视频录屏 Demo ·")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 64)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 版本号

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(v) (\(b))"
    }
}
