//
//  CertificationView.swift
//  EncryptFile
//
//  Created by Michael Safir on 08.01.2023.
//

import SwiftUI

struct CertificationView: View {
    @State var certificateOIDs: [CertificateOID] = []
    var body: some View {
        VStack(alignment: .leading) {
            if !self.certificateOIDs.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(
                            self.certificateOIDs,
                            id: \.self
                        ) { item in
                            HStack {
                                VStack(
                                    alignment:
                                        .leading,
                                    spacing:
                                        5
                                ) {
                                    Text(
                                        item
                                            .name
                                    )
                                    .modifier(
                                        NCRPTTextMedium(
                                            size:
                                                14
                                        )
                                    )
                                    .foregroundColor(
                                        Color
                                            .init(
                                                hex:
                                                    "21205A"
                                            )
                                    )
                                    //                                    Text(item.value)
                                    //                                        .modifier(NCRPTTextMedium(size: 16))
                                }
                                Spacer()
                                Text(
                                    item
                                        .value
                                        ?? "-"
                                )
                                .modifier(
                                    NCRPTTextMedium(
                                        size:
                                            14
                                    )
                                )
                                .padding(
                                    .leading
                                )
                                .opacity(
                                    0.7
                                )
                            }
                            Divider()
                        }
                    }.padding(.horizontal)
                    Spacer()
                }
            }
            else {
                VStack {
                    ActivityIndicator(
                        isAnimating: .constant(true),
                        style: .large
                    )
                    .foregroundColor(.secondary)

                    Text("loading")
                        .modifier(NCRPTTextMedium(size: 16))
                }
            }
        }
        .navigationTitle("certificates")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let certification = Certification()
                certification.getCertificate()
                DispatchQueue.main.async {
                    self.certificateOIDs =
                        certification.certificate
                        .certificationOIDs
                }
            }
        }
    }
}
