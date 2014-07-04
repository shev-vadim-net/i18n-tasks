# coding: utf-8
require 'spec_helper'

describe 'Tree siblings / forest' do

  context 'Node' do
    it '::new with children' do
      children = I18n::Tasks::Data::Tree::Siblings.from_key_attr([['a', value: 1]])
      node = I18n::Tasks::Data::Tree::Node.new(
          key: 'fr',
          children: children
      )
      expect(node.to_siblings.first.children.parent.key).to eq 'fr'
    end
  end

  context 'a tree' do
    let(:a_hash) { {'a' => 1, 'b' => {'ba' => 1, 'bb' => 2}} }

    it '::from_nested_hash' do
      a = build_tree(a_hash)
      expect(a.to_hash).to eq(a_hash)
    end

    it '#derive' do
      a = build_tree(a_hash)
      b = a.derive.append! build_tree(c: 1)

      # a was not modified
      expect(a.to_hash).to eq(a_hash)
      # but b was
      expect(b.to_hash).to eq(a_hash.merge('c' => 1))
    end

    it '#merge' do
      a      = build_tree(a_hash)
      b_hash = {'b' => {'bc' => 1}, 'c' => 1}
      expect(a.merge(build_tree(b_hash)).to_hash).to eq(a_hash.deep_merge(b_hash))
    end

    it '#intersect' do
      x = {a: 1, b: {ba: 1, bb: 2}}
      y = {b: {ba: 1, bc: 3}, c: 1}
      intersection = {'b' => {'ba' => 1}}
      a = build_tree(x)
      b = build_tree(y)
      expect(a.intersect_keys(b, root: true).to_hash).to eq(intersection)
    end

    it '#select_keys' do
      expect(build_tree(a: 1, b: 1).select_keys {|k, node| k == 'b'}.to_hash).to eq({'b' => 1})
    end

    it '#siblings' do
      t = build_tree(a: 1, b: 2).merge!(c: 1)
      expect(t.first.siblings).to eq(t)
      expect(t.first.siblings).to eq(t.reverse_each.first.siblings)
      expect(t.first.siblings).to eq(t.each.tap(&:next).next.siblings)
    end
  end
end
