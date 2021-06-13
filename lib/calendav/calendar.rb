# frozen_string_literal: true

require_relative "./xml_processor"

module Calendav
  class Calendar
    attr_reader :path

    def self.from_xml(node)
      new(
        node.xpath("./dav:href").text,
        node.xpath(".//dav:prop/*").to_xml,
        node.namespaces
      )
    end

    def initialize(path, attribute_nodes, namespaces = {})
      @path = path
      @attribute_nodes = attribute_nodes
      @namespaces = namespaces
    end

    def display_name
      attribute_value fragment.xpath("//dav:displayname")
    end

    def ctag
      attribute_value fragment.xpath("//cs:getctag")
    end

    def etag
      attribute_value fragment.xpath("//dav:getetag")
    end

    private

    attr_reader :attribute_nodes, :namespaces

    def fragment
      @fragment ||= XMLProcessor.call(
        "<nodes>#{attribute_nodes}</nodes>", namespaces
      )
    end

    def attribute_value(node)
      return nil if node.children.empty?

      if node.children.any?(&:element?)
        node.children.select(&:element?).collect(&:to_xml).join
      else
        node.children.text
      end
    end
  end
end
